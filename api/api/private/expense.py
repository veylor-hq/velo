import os
from datetime import datetime
from io import BytesIO
from typing import Optional, List

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from PIL import Image, ImageOps
from pydantic import BaseModel

from app.core.config import config
from app.core.jwt import FastJWT
from models.models import Car, ExpenseRecord, ExpenseType

expense_router = APIRouter(prefix="/expense")
UPLOAD_DIR = "static/expenses"

class ExpenseRecordCreate(BaseModel):
    date: datetime
    amount: float
    type: ExpenseType = ExpenseType.OTHER
    notes: Optional[str] = None

@expense_router.get("/")
async def get_expense_records(
    car_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    records = await ExpenseRecord.find(ExpenseRecord.car_id == car_id).sort(-ExpenseRecord.date).to_list()
    
    result = []
    for r in records:
        r_dump = r.model_dump(by_alias=True)
        r_dump['id'] = str(r.id)
        if r.has_photo:
            r_dump['photo_url'] = f"{config.API_BASE_URL}/api/static/expenses/{r.id}.jpg"
        result.append(r_dump)

    return result

@expense_router.post("/")
async def create_expense_record(
    car_id: PydanticObjectId,
    data: str = Form(...),
    photo: Optional[UploadFile] = File(None),
    user=Depends(FastJWT().login_required),
):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    try:
        payload = ExpenseRecordCreate.model_validate_json(data)
    except Exception:
        raise HTTPException(status_code=422, detail="Invalid data format")

    record = ExpenseRecord(
        car_id=car_id,
        date=payload.date,
        amount=payload.amount,
        type=payload.type,
        notes=payload.notes,
        has_photo=bool(photo)
    )
    await record.insert()

    if photo:
        filename = f"{record.id}.jpg"
        file_path = os.path.join(UPLOAD_DIR, filename)
        try:
            content = await photo.read()
            with Image.open(BytesIO(content)) as img:
                img = ImageOps.exif_transpose(img)
                rgb_img = img.convert("RGB")
                rgb_img.save(file_path, "JPEG", quality=40)
        except Exception as e:
            record.has_photo = False
            await record.save()

    r_dump = record.model_dump(by_alias=True)
    r_dump['id'] = str(record.id)
    if record.has_photo:
        r_dump['photo_url'] = f"{config.API_BASE_URL}/api/static/expenses/{record.id}.jpg"
    return r_dump

class ExpenseRecordUpdate(BaseModel):
    date: Optional[datetime] = None
    amount: Optional[float] = None
    type: Optional[ExpenseType] = None
    notes: Optional[str] = None

@expense_router.patch("/{record_id}")
async def update_expense_record(
    car_id: PydanticObjectId,
    record_id: PydanticObjectId,
    data: Optional[str] = Form(None),
    photo: Optional[UploadFile] = File(None),
    user=Depends(FastJWT().login_required),
):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")
    
    record = await ExpenseRecord.find_one(ExpenseRecord.id == record_id, ExpenseRecord.car_id == car_id)
    if not record:
        raise HTTPException(status_code=404, detail="Expense record not found")

    if data:
        try:
            update_data = ExpenseRecordUpdate.model_validate_json(data)
            update_dict = update_data.model_dump(exclude_unset=True)
            for key, value in update_dict.items():
                setattr(record, key, value)
        except Exception:
            raise HTTPException(status_code=422, detail="Invalid data format")

    if photo:
        filename = f"{record.id}.jpg"
        file_path = os.path.join(UPLOAD_DIR, filename)
        try:
            content = await photo.read()
            with Image.open(BytesIO(content)) as img:
                img = ImageOps.exif_transpose(img)
                rgb_img = img.convert("RGB")
                rgb_img.save(file_path, "JPEG", quality=40)
            record.has_photo = True
        except Exception as e:
            pass

    await record.save()

    r_dump = record.model_dump(by_alias=True)
    r_dump['id'] = str(record.id)
    if record.has_photo:
        r_dump['photo_url'] = f"{config.API_BASE_URL}/api/static/expenses/{record.id}.jpg"
    return r_dump

@expense_router.delete("/{record_id}")
async def delete_expense_record(
    car_id: PydanticObjectId,
    record_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    if not await Car.find_one(Car.id == car_id, Car.user_id == user.id):
        raise HTTPException(status_code=404, detail="Car not found")
    
    record = await ExpenseRecord.find_one(ExpenseRecord.id == record_id, ExpenseRecord.car_id == car_id)
    if not record:
        raise HTTPException(status_code=404, detail="Expense record not found")

    if record.has_photo:
        file_path = os.path.join(UPLOAD_DIR, f"{record.id}.jpg")
        if os.path.exists(file_path):
            os.remove(file_path)

    await record.delete()
    return {"message": "Expense record deleted"}
