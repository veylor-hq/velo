from datetime import datetime, timezone
import os
from io import BytesIO
from typing import Optional

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from PIL import Image
from pydantic import BaseModel

from app.core.config import config
from app.core.jwt import FastJWT
from models.models import SupplyRecord


supply_router = APIRouter(prefix="/supply")


class CreateSupplyRecord(BaseModel):
    part_number: Optional[str] = None
    name: str
    quantity: Optional[int] = 0
    price_per_unit: float = 0
    is_tool: bool = False
    vendor: Optional[str] = None
    notes: Optional[str] = None

class UpdateSupplyRecord(BaseModel):
    part_number: Optional[str] = None
    name: Optional[str] = None
    quantity: Optional[int] = None
    price_per_unit: Optional[float] = None
    is_tool: Optional[bool] = None
    vendor: Optional[str] = None
    notes: Optional[str] = None

@supply_router.post("/")
async def create_supply_record(
    payload: CreateSupplyRecord,
    user=Depends(FastJWT().login_required),
):  
    supply_record = SupplyRecord(user_id=user.id, **payload.model_dump())
    await supply_record.insert()

    return supply_record 


@supply_router.get("/")
async def get_supply_records(
    user=Depends(FastJWT().login_required),
):
    supply_records = await SupplyRecord.find(SupplyRecord.user_id == user.id).to_list()
    return supply_records

@supply_router.get("/{record_id}")
async def get_supply_record(
    record_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    record = await SupplyRecord.find_one(SupplyRecord.id == record_id, SupplyRecord.user_id == user.id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    
    return record

@supply_router.delete("/{record_id}")
async def delete_supply_record(
    record_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    record = await SupplyRecord.find_one(SupplyRecord.id == record_id, SupplyRecord.user_id == user.id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    
    await record.delete()
    return {"message": "Record deleted"}


@supply_router.patch("/{record_id}")
async def update_supply_record(
    record_id: PydanticObjectId,
    payload: UpdateSupplyRecord,
    user=Depends(FastJWT().login_required),
):
    record = await SupplyRecord.find_one(SupplyRecord.id == record_id, SupplyRecord.user_id == user.id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    
    update_data = payload.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(record, key, value)
    
    record.updated_at = datetime.now(timezone.utc)
    await record.save()
    return record