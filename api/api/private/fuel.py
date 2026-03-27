from datetime import datetime
import os
from io import BytesIO
from typing import Optional

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from PIL import Image
from pydantic import BaseModel

from app.core.config import config
from app.core.jwt import FastJWT
from models.models import Car, FuelRecord

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

    return fuel_record