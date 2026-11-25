import os

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/sabores_del_valle",
)

APP_NAME = "Sabores del Valle — Administración de productos"
APP_VERSION = "1.0.0"
