from datetime import datetime
from typing import Optional, List

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.core.jwt import FastJWT
from models.models import Car, ServiceRecord, ServiceSupplyItem, SupplyRecord, OdometerRecord

service_router = APIRouter(prefix="/service")

class ServiceSupplyItemCreate(BaseModel):
    supply_id: PydanticObjectId
    quantity: int
    price_per_unit: Optional[float] = None

class ServiceRecordCreate(BaseModel):
    date: datetime
    odometer: int
    total_cost: float
    notes: Optional[str] = None
    insert_odometer_record: bool = False
    supplies_used: List[ServiceSupplyItemCreate] = []

@service_router.get("/")
async def get_service_records(
    car_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    records = await ServiceRecord.find(ServiceRecord.car_id == car_id).sort(-ServiceRecord.date).to_list()
    return records

@service_router.post("/")
async def create_service_record(
    car_id: PydanticObjectId,
    payload: ServiceRecordCreate,
    user=Depends(FastJWT().login_required),
):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user.id)
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    # Validate and deduct supplies
    processed_supplies = []
    for item in payload.supplies_used:
        supply = await SupplyRecord.find_one(SupplyRecord.id == item.supply_id, SupplyRecord.user_id == user.id)
        if not supply:
            raise HTTPException(status_code=400, detail=f"Supply {item.supply_id} not found")
        if supply.quantity < item.quantity:
            raise HTTPException(status_code=400, detail=f"Insufficient quantity for {supply.name}. Available: {supply.quantity}")
        
        supply.quantity -= item.quantity
        await supply.save()
        price = item.price_per_unit if item.price_per_unit is not None else supply.price_per_unit
        processed_supplies.append(ServiceSupplyItem(supply_id=item.supply_id, name=supply.name, quantity=item.quantity, price_per_unit=price))

    record = ServiceRecord(
        car_id=car_id,
        date=payload.date,
        odometer=payload.odometer,
        total_cost=payload.total_cost,
        notes=payload.notes,
        supplies_used=processed_supplies
    )
    await record.insert()

    if payload.insert_odometer_record:
        odo = OdometerRecord(car_id=car_id, date=payload.date, odometer=payload.odometer, notes="Auto-inserted from Service")
        await odo.insert()

    return record

@service_router.delete("/{record_id}")
async def delete_service_record(
    car_id: PydanticObjectId,
    record_id: PydanticObjectId,
    user=Depends(FastJWT().login_required),
):
    if not await Car.find_one(Car.id == car_id, Car.user_id == user.id):
        raise HTTPException(status_code=404, detail="Car not found")
    
    record = await ServiceRecord.find_one(ServiceRecord.id == record_id, ServiceRecord.car_id == car_id)
    if not record:
        raise HTTPException(status_code=404, detail="Service record not found")
    
    # Restore supplies
    for item in record.supplies_used:
        supply = await SupplyRecord.find_one(SupplyRecord.id == item.supply_id, SupplyRecord.user_id == user.id)
        if supply:
            supply.quantity += item.quantity
            await supply.save()

    await record.delete()
    return {"message": "Service record deleted"}

class ServiceRecordUpdate(BaseModel):
    date: Optional[datetime] = None
    odometer: Optional[int] = None
    total_cost: Optional[float] = None
    notes: Optional[str] = None
    supplies_used: Optional[List[ServiceSupplyItemCreate]] = None

@service_router.patch("/{record_id}")
async def update_service_record(
    car_id: PydanticObjectId,
    record_id: PydanticObjectId,
    payload: ServiceRecordUpdate,
    user=Depends(FastJWT().login_required),
):
    if not await Car.find_one(Car.id == car_id, Car.user_id == user.id):
        raise HTTPException(status_code=404, detail="Car not found")
    
    record = await ServiceRecord.find_one(ServiceRecord.id == record_id, ServiceRecord.car_id == car_id)
    if not record:
        raise HTTPException(status_code=404, detail="Service record not found")

    if payload.supplies_used is not None:
        all_involved_supply_ids = set([s.supply_id for s in record.supplies_used] + [s.supply_id for s in payload.supplies_used])
        supplies_db = {s.id: s for s in await SupplyRecord.find({"_id": {"$in": list(all_involved_supply_ids)}, "user_id": user.id}).to_list()}

        # Revert old quantities in memory
        for old_item in record.supplies_used:
            if old_item.supply_id in supplies_db:
                supplies_db[old_item.supply_id].quantity += old_item.quantity

        # Deduct new quantities
        processed_supplies = []
        for new_item in payload.supplies_used:
            if new_item.supply_id not in supplies_db:
                raise HTTPException(status_code=400, detail=f"Supply {new_item.supply_id} not found")
            s_obj = supplies_db[new_item.supply_id]
            if s_obj.quantity < new_item.quantity:
                raise HTTPException(status_code=400, detail=f"Insufficient quantity for {s_obj.name}. Available: {s_obj.quantity}")
            
            s_obj.quantity -= new_item.quantity
            price = new_item.price_per_unit if new_item.price_per_unit is not None else s_obj.price_per_unit
            processed_supplies.append(ServiceSupplyItem(supply_id=new_item.supply_id, name=s_obj.name, quantity=new_item.quantity, price_per_unit=price))

        # Save supplies
        for s_obj in supplies_db.values():
            await s_obj.save()
            
        record.supplies_used = processed_supplies

    update_data = payload.model_dump(exclude_unset=True, exclude={"supplies_used"})
    for key, value in update_data.items():
        setattr(record, key, value)
    
    await record.save()
    return record
