from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Optional

from beanie import Document, PydanticObjectId
from pydantic import BaseModel, Field


class User(Document):
    email: str
    password: str
    email_verified: bool = False
    notification_settings: "NotificationSettings" = Field(
        default_factory=lambda: NotificationSettings()
    )
    created_at: datetime = Field(default_factory=datetime.utcnow)
    telegram_chat_id: Optional[str] = None
    connection_code: Optional[str] = None

    class Settings:
        name = "user"


class NotificationSettings(BaseModel):
    email_on_signin: bool = False
    email_on_password_reset: bool = False


class OTPActivationModel(Document):
    class Settings:
        name = "otp_activation"

    user_id: PydanticObjectId
    otp: str
    expires_at: datetime


class PasswordResetToken(Document):
    class Settings:
        name = "password_reset_token"
        indexes = [
            "token",
            "user_id",
            "expires_at",
        ]

    user_id: PydanticObjectId
    token: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    expires_at: datetime
    used_at: Optional[datetime] = None


class FuelType(str, Enum):
    petrol = "petrol"
    diesel = "diesel"
    electric = "electric"
    hybrid = "hybrid"
    other = "other"
    # Add more fuel types like gas?

class CarSalesMeta(BaseModel):
    price_bought: Optional[float] = None
    price_sold: Optional[float] = None
    date_bought: Optional[datetime] = None
    date_sold: Optional[datetime] = None

class OdometerUnit(str, Enum):
    KILOMETERS = "km"
    MILES = "mi"

class FuelUnit(str, Enum):
    LITERS = "l"
    GALLONS = "gal"

class Car(Document):
    user_id: PydanticObjectId
    license_plate: str
    make: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    color: Optional[str] = None
    vin: Optional[str] = None
    
    odometer_unit: OdometerUnit = OdometerUnit.KILOMETERS
    fuel_unit: FuelUnit = FuelUnit.LITERS
    
    current_odometer: int = 0
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "car"

        model_config = {
            "populate_by_name": True,
            "json_encoders": {PydanticObjectId: str}
        }

class FuelRecord(Document):
    car_id: PydanticObjectId
    date: datetime
    odometer: int
    fuel_amount: float

    price_per_unit: float 
    total_cost: float

    is_full_tank: bool = True
    skip_mpg_calculation: bool = False
    
    notes: Optional[str] = None

    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "fuel_record"
        
    model_config = {
        "populate_by_name": True,
        "json_encoders": {PydanticObjectId: str}
    }

class SupplyRecord(Document):
    user_id: PydanticObjectId
    part_number: Optional[str] = None
    name: str
    quantity: int = 1
    price_per_unit: float = 0
    vendor: Optional[str] = None
    notes: Optional[str] = None
    is_tool: bool = False
    date: Optional[datetime] = Field(default_factory=datetime.utcnow)

    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "supply_record"