from datetime import datetime
import os
from io import BytesIO
from typing import Optional

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from PIL import Image
from pydantic import BaseModel

from app.core.jwt import FastJWT
from models.models import Car, FuelRecord
from api.private.odometer import create_odometer_record, OdometerRecordCreate

UPLOAD_DIR = "static/fuel_records"

fuel_router = APIRouter(prefix="/fuel")

class CreateFuelRecord(BaseModel):
    date: datetime
    odometer: int
    fuel_amount: float
    total_cost: float
    is_full_tank: bool = True
    notes: Optional[str] = None
    skip_mpg_calculation: bool = False
    insert_odometer_record: bool = True
    

@fuel_router.post("/")
async def create_fuel_record(
    car_id: PydanticObjectId,
    data: str = Form(...),
    photo: Optional[UploadFile] = File(None),
    user=Depends(FastJWT().login_required),
):
    try:
        fuel_data = CreateFuelRecord.model_validate_json(data)
    except Exception:
        raise HTTPException(status_code=422, detail="Invalid metadata format")

    car = await Car.find_one(
        Car.user_id == user.id,
        Car.id == car_id,
    )
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")
    
    fuel_record = FuelRecord(
        car_id=car_id,
        date=fuel_data.date,
        odometer=fuel_data.odometer,
        fuel_amount=fuel_data.fuel_amount,
        total_cost=fuel_data.total_cost,
        price_per_unit=fuel_data.total_cost / fuel_data.fuel_amount if fuel_data.fuel_amount > 0 else 0,
        is_full_tank=fuel_data.is_full_tank,
        notes=fuel_data.notes,
        skip_mpg_calculation=fuel_data.skip_mpg_calculation,
    )
    await fuel_record.insert()

    if photo:
        filename = f"{user.id}-{car_id}-{fuel_record.id}.jpg"
        file_path = os.path.join(UPLOAD_DIR, filename)

        try:
            content = await photo.read()
            with Image.open(BytesIO(content)) as img:
                rgb_img = img.convert("RGB")
                rgb_img.save(file_path, "JPEG", quality=20)
        except Exception:
            await fuel_record.delete()
            raise HTTPException(status_code=400, detail="Invalid image format")

    if fuel_data.odometer > car.current_odometer:
        car.current_odometer = fuel_data.odometer
        await car.save()

    if fuel_data.insert_odometer_record:
        odometer_record = await create_odometer_record(
            car_id=car_id,
            payload=OdometerRecordCreate(
                date=fuel_data.date,
                odometer=fuel_data.odometer,
                notes="Auto-generated from fuel record"
            ),
            user=user
        )

    return {
        "fuel_record": fuel_record,
        "odometer_record": odometer_record if fuel_data.insert_odometer_record else None
    }


@fuel_router.get("/")
async def get_fuel_records(
    car_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    fuel_records = await FuelRecord.find(FuelRecord.car_id == car_id).to_list()

    sorted_records = sorted(fuel_records, key=lambda r: r.odometer)
    
    result = []
    previous_odometer = None
    
    for record in sorted_records:
        record_dict = record.model_dump(exclude={"id", "_id", "car_id"}, by_alias=True)
        
        record_dict["id"] = str(record.id)
        record_dict["car_id"] = str(record.car_id)
        
        if previous_odometer is not None:
            record_dict["delta_mileage"] = record.odometer - previous_odometer
        else:
            record_dict["delta_mileage"] = 0
            
        previous_odometer = record.odometer
        result.append(record_dict)

    result.reverse()

    return result

class UpdateFuelRecord(BaseModel):
    date: Optional[datetime] = None
    odometer: Optional[int] = None
    fuel_amount: Optional[float] = None
    total_cost: Optional[float] = None
    is_full_tank: Optional[bool] = None
    notes: Optional[str] = None
    skip_mpg_calculation: Optional[bool] = None


@fuel_router.patch("/{record_id}")
async def update_fuel_record(
    car_id: PydanticObjectId,
    record_id: PydanticObjectId,
    data: Optional[str] = Form(None),
    photo: Optional[UploadFile] = File(None),
    user=Depends(FastJWT().login_required),
):  
    fuel_record = await FuelRecord.find_one(
        FuelRecord.car_id == car_id,
        FuelRecord.id == record_id,
    )
    if not fuel_record:
        raise HTTPException(status_code=404, detail="Fuel record not found")
    
    if data:
        try:
            update_data = UpdateFuelRecord.model_validate_json(data)
            update_dict = update_data.model_dump(exclude_unset=True)
            
            for key, value in update_dict.items():
                setattr(fuel_record, key, value)
            if "fuel_amount" in update_dict or "total_cost" in update_dict:
                fuel_record.price_per_unit = fuel_record.total_cost / fuel_record.fuel_amount if fuel_record.fuel_amount > 0 else 0
            await fuel_record.save()
        except Exception:
            raise HTTPException(status_code=422, detail="Invalid metadata format")
        
    if photo:
        filename = f"{user.id}-{car_id}-{fuel_record.id}.jpg"
        file_path = os.path.join(UPLOAD_DIR, filename)

        try:
            content = await photo.read()
            with Image.open(BytesIO(content)) as img:
                rgb_img = img.convert("RGB")
                rgb_img.save(file_path, "JPEG", quality=20)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image format")
        
    return fuel_record

@fuel_router.delete("/{record_id}")
async def delete_fuel_record(
    car_id: PydanticObjectId,
    record_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    fuel_record = await FuelRecord.find_one(
        FuelRecord.car_id == car_id,
        FuelRecord.id == record_id,
    )
    if not fuel_record:
        raise HTTPException(status_code=404, detail="Fuel record not found")
    
    await fuel_record.delete()

    file_path = os.path.join(UPLOAD_DIR, f"{user.id}-{car_id}-{record_id}.jpg")
    if os.path.exists(file_path):
        os.remove(file_path)

    return {"detail": "Fuel record deleted"}