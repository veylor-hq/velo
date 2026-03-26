import os

from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse

static_router = APIRouter(prefix="/static", tags=["static"])


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

