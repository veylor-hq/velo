from datetime import datetime
import os
from io import BytesIO
from typing import Optional

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from PIL import Image, ImageOps
from pydantic import BaseModel

from app.core.config import config
from app.core.jwt import FastJWT
from models.models import Car, FuelUnit, OdometerUnit, FuelRecord, ServiceRecord, ExpenseRecord, OdometerRecord
from api.private.fuel import fuel_router
from api.private.odometer import odometer_router, create_odometer_record, OdometerRecordCreate

UPLOAD_DIR = "static/cars"

car_router = APIRouter(prefix="/car")

class CarSalesMetaSchema(BaseModel):
    price_bought: Optional[float] = None
    price_sold: Optional[float] = None
    date_bought: Optional[datetime] = None
    date_sold: Optional[datetime] = None

class CreateCar(BaseModel):
    license_plate: str
    make: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    color: Optional[str] = None
    vin: Optional[str] = None
    odometer_unit: OdometerUnit = OdometerUnit.KILOMETERS
    fuel_unit: FuelUnit = FuelUnit.LITERS
    initial_odometer: int = 0
    sales_meta: Optional[CarSalesMetaSchema] = None


@car_router.post("/")
async def create_car(
    data: str = Form(...),
    photo: UploadFile = File(...),
    user=Depends(FastJWT().login_required),
):
    try:
        car_data = CreateCar.model_validate_json(data)
    except Exception:
        raise HTTPException(status_code=422, detail="Invalid metadata format")

    existing_car = await Car.find_one(
        Car.user_id == user.id,
        Car.license_plate == car_data.license_plate,
    )
    if existing_car:
        raise HTTPException(
            status_code=400, detail="This plate is already in your garage"
        )

    car = Car(
        user_id=user.id,
        license_plate=car_data.license_plate,
        make=car_data.make,
        model=car_data.model,
        year=car_data.year,
        odometer_unit=car_data.odometer_unit,
        fuel_unit=car_data.fuel_unit,
        current_odometer=car_data.initial_odometer,
        sales_meta= car_data.sales_meta.model_dump() if car_data.sales_meta else None,
        color=car_data.color,
        vin=car_data.vin,
    )
    await car.insert()

    if car_data.initial_odometer > 0:
        from models.models import OdometerRecord
        odo = OdometerRecord(car_id=car.id, date=datetime.utcnow(), odometer=car_data.initial_odometer, notes="Initial Odometer")
        await odo.insert()

    filename = f"{user.id}-{car.id}.jpg"
    file_path = os.path.join(UPLOAD_DIR, filename)

    try:
        content = await photo.read()
        with Image.open(BytesIO(content)) as img:
            img = ImageOps.exif_transpose(img)
            rgb_img = img.convert("RGB")
            rgb_img.save(file_path, "JPEG", quality=20)
    except Exception as e:
        await car.delete()
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=400, detail=f"Invalid image format: {str(e)}")

    return {
        "id": str(car.id),
        "license_plate": car.license_plate,
        "photo_url": f"{config.API_BASE_URL}/api/static/cars/{filename}",
    }

@car_router.get("/")
async def get_cars(user=Depends(FastJWT().login_required)):
    cars = Car.find(Car.user_id == user.id)
    return {
        "cars": [
            {
                "id": str(car.id),
                "license_plate": car.license_plate,
                "photo_filename": f"{user.id}-{car.id}.jpg",
            }
            for car in await cars.to_list()
        ],
        "base_url": f"{config.API_BASE_URL}/api/static/cars/",
    }


@car_router.get("/stats/overall")
async def get_garage_stats(user=Depends(FastJWT().login_required)):
    cars = await Car.find(Car.user_id == user.id).to_list()
    
    total_spent = 0.0
    
    total_distance_by_unit = {
        OdometerUnit.KILOMETERS: 0.0,
        OdometerUnit.MILES: 0.0,
    }
    
    total_fuel_amount_by_unit = {
        FuelUnit.LITERS: 0.0,
        FuelUnit.GALLONS: 0.0,
    }
    
    total_spent = 0.0
    total_fuel_cost = 0.0
    total_services = 0.0
    total_expenses = 0.0

    for car in cars:
        odo_records = await OdometerRecord.find(OdometerRecord.car_id == car.id).sort(+OdometerRecord.date).to_list()
        if odo_records:
            min_odo = odo_records[0].odometer
            max_odo = car.current_odometer or odo_records[-1].odometer
            if max_odo > min_odo:
                total_distance_by_unit[car.odometer_unit] += (max_odo - min_odo)
                
        fuel_records = await FuelRecord.find(FuelRecord.car_id == car.id).to_list()
        for r in fuel_records:
            total_fuel_cost += r.total_cost
            total_spent += r.total_cost
            total_fuel_amount_by_unit[car.fuel_unit] += r.fuel_amount
            
        service_records = await ServiceRecord.find(ServiceRecord.car_id == car.id).to_list()
        for r in service_records:
            total_spent += r.total_cost
            total_services += r.total_cost
            for s in r.supplies_used:
                part_cost = s.price_per_unit * s.quantity
                total_spent += part_cost
                total_services += part_cost
                
        expense_records = await ExpenseRecord.find(ExpenseRecord.car_id == car.id).to_list()
        for r in expense_records:
            total_spent += r.amount
            total_expenses += r.amount

    return {
        "total_spent": total_spent,
        "total_fuel_cost": total_fuel_cost,
        "total_services": total_services,
        "total_expenses": total_expenses,
        "distance_by_unit": total_distance_by_unit,
        "fuel_amount_by_unit": total_fuel_amount_by_unit,
    }

@car_router.get("/{car_id}")
async def get_car(car_id: PydanticObjectId, user=Depends(FastJWT().login_required)):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    car_data = car.model_dump(
        exclude={"user_id", "created_at", "updated_at", "id", "_id"}, 
        by_alias=True
    )

    return {
        "id": str(car.id),
        "photo_url": f"{config.API_BASE_URL}/api/static/cars/{user.id}-{car.id}.jpg",
        **car_data,
    }

class UpdateCar(BaseModel):
    license_plate: Optional[str] = None
    make: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    color: Optional[str] = None
    vin: Optional[str] = None
    odometer_unit: Optional[OdometerUnit] = None
    fuel_unit: Optional[FuelUnit] = None
    current_odometer: Optional[int] = None
    sales_meta: Optional[CarSalesMetaSchema] = None

@car_router.patch("/{car_id}")
async def update_car(
    car_id: PydanticObjectId,
    data: Optional[str] = Form(None),
    photo: Optional[UploadFile] = File(None),
    user=Depends(FastJWT().login_required)
):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    if data:
        try:
            update_data = UpdateCar.model_validate_json(data)
            update_dict = update_data.model_dump(exclude_unset=True)
            
            if "license_plate" in update_dict and update_dict["license_plate"] != car.license_plate:
                existing_car = await Car.find_one(
                    Car.user_id == user.id,
                    Car.license_plate == update_dict["license_plate"]
                )
                if existing_car:
                    raise HTTPException(status_code=400, detail="This plate is already in your garage")
            
            for key, value in update_dict.items():
                setattr(car, key, value)
                
        except HTTPException:
            raise
        except Exception:
            raise HTTPException(status_code=422, detail="Invalid metadata format")

    if photo:
        filename = f"{user.id}-{car.id}.jpg"
        file_path = os.path.join(UPLOAD_DIR, filename)
        try:
            content = await photo.read()
            with Image.open(BytesIO(content)) as img:
                img = ImageOps.exif_transpose(img)
                rgb_img = img.convert("RGB")
                rgb_img.save(file_path, "JPEG", quality=20)
        except Exception as e:
            import traceback
            traceback.print_exc()
            raise HTTPException(status_code=400, detail=f"Invalid image format: {str(e)}")

    car.updated_at = datetime.utcnow()
    await car.save()

    car_dump = car.model_dump(
        exclude={"user_id", "created_at", "updated_at", "id", "_id"}, 
        by_alias=True
    )

    return {
        "id": str(car.id),
        "photo_url": f"{config.API_BASE_URL}/api/static/cars/{user.id}-{car.id}.jpg",
        **car_dump,
    }


car_router.include_router(fuel_router, prefix="/{car_id}")
car_router.include_router(odometer_router, prefix="/{car_id}")