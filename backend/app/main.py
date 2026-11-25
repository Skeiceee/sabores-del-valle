from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .config import APP_NAME, APP_VERSION
from .db import close_pool, open_pool
from .routers import auditoria, catalogo, dashboard, lotes, productos


@asynccontextmanager
async def lifespan(_: FastAPI):
    open_pool()
    yield
    close_pool()


app = FastAPI(title=APP_NAME, version=APP_VERSION, lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(productos.router)
app.include_router(lotes.router)
app.include_router(catalogo.router)
app.include_router(dashboard.router)
app.include_router(auditoria.router)


@app.get("/api/salud", tags=["sistema"])
def salud():
    return {"estado": "ok", "version": APP_VERSION}


@app.exception_handler(Exception)
async def error_general(_, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": f"Error interno: {exc}"},
    )
