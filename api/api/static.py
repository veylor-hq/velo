import os

from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

static_router = APIRouter(prefix="/static", tags=["static"])

static_router.mount("/cars", StaticFiles(directory="static/cars"), name="cars")
static_router.mount(
    "/fuel_records", StaticFiles(directory="static/fuel_records"), name="fuel_records"
)
static_router.mount(
    "/expenses", StaticFiles(directory="static/expenses"), name="expenses"
)

@static_router.get("/cars/{filename}")
async def get_car_image(filename: str):
    """
    Serves car images.
    Publicly accessible via UUID-based filenames.
    """
    file_path = os.path.join("static/cars", filename)

    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Image not found")

    return FileResponse(file_path)

@static_router.get("/expenses/{filename}")
async def get_expense_image(filename: str):
    file_path = os.path.join("static/expenses", filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Image not found")
    return FileResponse(file_path)

