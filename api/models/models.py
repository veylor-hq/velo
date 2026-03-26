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


class Car(Document):
    user_id: PydanticObjectId
    license_plate: str

    class Settings:
        name = "car"
