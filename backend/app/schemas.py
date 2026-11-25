from datetime import date, datetime

from pydantic import BaseModel, Field, field_validator


def _limpiar(valor: str | None) -> str | None:
    if valor is None:
        return None
    valor = valor.strip()
    return valor or None


class ProductoBase(BaseModel):
    sku: str = Field(min_length=1, max_length=30)
    tipo_producto_id: int
    nombre: str = Field(min_length=1, max_length=150)
    formato: str | None = Field(default=None, max_length=80)
    precio_venta: float | None = Field(default=None, ge=0)
    descripcion: str | None = None
    ingredientes: str | None = None
    alergenos: str | None = None

    @field_validator("sku", "nombre", "formato", "descripcion", "ingredientes", "alergenos", mode="before")
    @classmethod
    def limpiar_textos(cls, valor):
        return _limpiar(valor) if isinstance(valor, str) else valor


class ProductoCrear(ProductoBase):
    pass


class ProductoEditar(ProductoBase):
    pass


class CambioEstado(BaseModel):
    activo: bool


class ProductoOut(ProductoBase):
    id: int
    tipo_producto: str
    activo: bool
    created_at: datetime
    updated_at: datetime
    lotes: int = 0
    stock_disponible: int = 0
    stock_reservado: int = 0
    stock_neto: int = 0
    proximo_vencimiento: date | None = None


class TipoProductoOut(BaseModel):
    id: int
    nombre: str


class LoteOut(BaseModel):
    id: int
    codigo: str
    producto_id: int
    sku: str
    producto: str
    tipo_producto: str
    fecha_elaboracion: date | None
    fecha_vencimiento: date | None
    stock_disponible: int
    stock_reservado: int
    stock_neto: int
    estado_vencimiento: str


class AuditoriaOut(BaseModel):
    id: int
    producto_id: int
    sku: str
    producto: str
    accion: str
    usuario: str
    detalle: str | None
    fecha: datetime


class TipoStockOut(BaseModel):
    tipo_producto: str
    productos: int
    stock_neto: int


class VencimientoOut(BaseModel):
    lote: str
    producto: str
    fecha_vencimiento: date
    dias_restantes: int
    stock_neto: int


class AlertaOut(BaseModel):
    tipo: str
    mensaje: str


class DashboardOut(BaseModel):
    productos_total: int
    productos_activos: int
    productos_ocultos: int
    lotes_total: int
    stock_disponible: int
    stock_reservado: int
    stock_neto: int
    lotes_por_vencer: int
    lotes_vencidos: int
    valor_stock: float
    por_tipo: list[TipoStockOut]
    proximos_vencimientos: list[VencimientoOut]
    alertas: list[AlertaOut]
