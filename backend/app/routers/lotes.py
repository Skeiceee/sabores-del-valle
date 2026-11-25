from fastapi import APIRouter, Query

from ..db import Conn
from ..schemas import LoteOut

router = APIRouter(prefix="/api/lotes", tags=["lotes"])

LOTE_SELECT = """
SELECT
    l.id,
    l.codigo,
    p.id AS producto_id,
    p.sku,
    p.nombre AS producto,
    t.nombre AS tipo_producto,
    l.fecha_elaboracion,
    l.fecha_vencimiento,
    l.stock_disponible,
    l.stock_reservado,
    l.stock_disponible - l.stock_reservado AS stock_neto,
    CASE
        WHEN l.fecha_vencimiento IS NULL THEN 'sin_fecha'
        WHEN l.fecha_vencimiento < CURRENT_DATE THEN 'vencido'
        WHEN l.fecha_vencimiento <= CURRENT_DATE + 30 THEN 'por_vencer'
        ELSE 'vigente'
    END AS estado_vencimiento
FROM lote l
JOIN producto p ON p.id = l.producto_id
JOIN tipo_producto t ON t.id = p.tipo_producto_id
"""


@router.get("", response_model=list[LoteOut])
def listar_lotes(
    conn=Conn,
    buscar: str | None = None,
    estado: str = Query("todos", pattern="^(todos|vigente|por_vencer|vencido|sin_stock)$"),
    tipo_producto_id: int | None = None,
):
    condiciones = []
    params: list = []

    if buscar:
        patron = f"%{buscar.strip()}%"
        condiciones.append("(p.nombre ILIKE %s OR p.sku ILIKE %s OR l.codigo ILIKE %s)")
        params.extend([patron, patron, patron])

    if tipo_producto_id:
        condiciones.append("p.tipo_producto_id = %s")
        params.append(tipo_producto_id)

    if estado == "sin_stock":
        condiciones.append("l.stock_disponible - l.stock_reservado <= 0")
    elif estado == "vencido":
        condiciones.append("l.fecha_vencimiento < CURRENT_DATE")
    elif estado == "por_vencer":
        condiciones.append(
            "l.fecha_vencimiento >= CURRENT_DATE AND l.fecha_vencimiento <= CURRENT_DATE + 30"
        )
    elif estado == "vigente":
        condiciones.append(
            "(l.fecha_vencimiento IS NULL OR l.fecha_vencimiento > CURRENT_DATE + 30)"
        )

    where = f" WHERE {' AND '.join(condiciones)}" if condiciones else ""
    return conn.execute(
        LOTE_SELECT
        + where
        + " ORDER BY (l.fecha_vencimiento IS NULL), l.fecha_vencimiento, p.nombre, l.codigo",
        params,
    ).fetchall()
