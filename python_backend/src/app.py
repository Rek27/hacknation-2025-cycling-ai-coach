from fastapi import FastAPI
from src.api.routers import health


def app() -> FastAPI:
    project = FastAPI(title="Temp", version="1.0.0")
    project.include_router(health.router)

    return project