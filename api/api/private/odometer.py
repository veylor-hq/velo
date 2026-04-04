from datetime import datetime
from typing import Optional

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.core.jwt import FastJWT
from models.models import Car, OdometerRecord

odometer_router = APIRouter(prefix="/odometer")

class OdometerRecordCreate(BaseModel):
    date: datetime
    odometer: int
    notes: Optional[str] = None

@odometer_router.get("/")
async def get_odometer_records(
    car_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    records = await OdometerRecord.find(OdometerRecord.car_id == car_id).sort(-OdometerRecord.date).to_list()
    return records

@odometer_router.post("/")
async def create_odometer_record(
    car_id: PydanticObjectId,
    payload: OdometerRecordCreate,
    user=Depends(FastJWT().login_required),
):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    record = OdometerRecord(
        car_id=car_id,
        date=payload.date,
        odometer=payload.odometer,
        notes=payload.notes
    )
    await record.insert()
    return record


@odometer_router.delete("/{record_id}")
async def delete_odometer_record(
    car_id: PydanticObjectId,
    record_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    if not await Car.find_one(Car.id == car_id, Car.user_id == user.id):
        raise HTTPException(status_code=404, detail="Car not found")
    
    record = await OdometerRecord.find_one(OdometerRecord.id == record_id, OdometerRecord.car_id == car_id)
    if not record:
        raise HTTPException(status_code=404, detail="Odometer record not found")
    
    await record.delete()
    return {"message": "Odometer record deleted"}

class OdometerRecordUpdate(BaseModel):
    date: Optional[datetime] = None
    odometer: Optional[int] = None
    notes: Optional[str] = None

@odometer_router.patch("/{record_id}")
async def update_odometer_record(
    car_id: PydanticObjectId,
    record_id: PydanticObjectId,
    payload: OdometerRecordUpdate,
    user=Depends(FastJWT().login_required),
):
    if not await Car.find_one(Car.id == car_id, Car.user_id == user.id):
        raise HTTPException(status_code=404, detail="Car not found")
    
    record = await OdometerRecord.find_one(OdometerRecord.id == record_id, OdometerRecord.car_id == car_id)
    if not record:
        raise HTTPException(status_code=404, detail="Odometer record not found")
    
    update_data = payload.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(record, key, value)
    
    await record.save()
    return record