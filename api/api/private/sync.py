from beanie import PydanticObjectId
from models.models import Car, OdometerRecord, FuelRecord, ServiceRecord

async def sync_car_odometer(car_id: PydanticObjectId, user_id: PydanticObjectId):
    car = await Car.find_one(Car.id == car_id, Car.user_id == user_id)
    if not car: return
    
    max_odo = 0
    
    odo_recs = await OdometerRecord.find(OdometerRecord.car_id == car_id).sort("-odometer").limit(1).to_list()
    if odo_recs and odo_recs[0].odometer > max_odo:
        max_odo = odo_recs[0].odometer
        
    fuel_recs = await FuelRecord.find(FuelRecord.car_id == car_id).sort("-odometer").limit(1).to_list()
    if fuel_recs and fuel_recs[0].odometer > max_odo:
        max_odo = fuel_recs[0].odometer
        
    service_recs = await ServiceRecord.find(ServiceRecord.car_id == car_id).sort("-odometer").limit(1).to_list()
    if service_recs and service_recs[0].odometer > max_odo:
        max_odo = service_recs[0].odometer
        
    if max_odo > 0 and car.current_odometer != max_odo:
        car.current_odometer = max_odo
        await car.save()
