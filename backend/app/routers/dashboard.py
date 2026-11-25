from fastapi import APIRouter

from ..db import Conn
from ..schemas import DashboardOut

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])


@router.get("", response_model=DashboardOut)
def dashboard(conn=Conn):
    productos = conn.execute(
        """
        SELECT count(*) AS total,
               count(*) FILTER (WHERE activo) AS activos,
               count(*) FILTER (WHERE NOT activo) AS ocultos
        FROM producto
        """
    ).fetchone()

    lotes = conn.execute(
        """
        SELECT count(*) AS total,
               COALESCE(sum(stock_disponible), 0) AS disponible,
               COALESCE(sum(stock_reservado), 0) AS reservado,
               count(*) FILTER (
                   WHERE fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + 30
               ) AS por_vencer,
               count(*) FILTER (WHERE fecha_vencimiento < CURRENT_DATE) AS vencidos
        FROM lote
        """
    ).fetchone()

    valor = conn.execute(
        """
        SELECT COALESCE(sum(l.stock_disponible * p.precio_venta), 0)::float8 AS valor
        FROM lote l
        JOIN producto p ON p.id = l.producto_id
        """
    ).fetchone()

    por_tipo = conn.execute(
        """
        SELECT t.nombre AS tipo_producto,
               count(DISTINCT p.id) AS productos,
               COALESCE(sum(l.stock_disponible - l.stock_reservado), 0) AS stock_neto
        FROM tipo_producto t
        LEFT JOIN producto p ON p.tipo_producto_id = t.id AND p.activo
        LEFT JOIN lote l ON l.producto_id = p.id
        GROUP BY t.id, t.nombre
        ORDER BY stock_neto DESC, t.nombre
        """
    ).fetchall()

    proximos = conn.execute(
        """
        SELECT l.codigo AS lote,
               p.nombre AS producto,
               l.fecha_vencimiento,
               (l.fecha_vencimiento - CURRENT_DATE) AS dias_restantes,
               (l.stock_disponible - l.stock_reservado) AS stock_neto
        FROM lote l
        JOIN producto p ON p.id = l.producto_id
        WHERE l.fecha_vencimiento IS NOT NULL
          AND l.fecha_vencimiento <= CURRENT_DATE + 60
        ORDER BY l.fecha_vencimiento
        LIMIT 8
        """
    ).fetchall()

    reservado_mayor = conn.execute(
        "SELECT count(*) AS n FROM lote WHERE stock_reservado > stock_disponible"
    ).fetchone()["n"]

    vencidos_con_stock = conn.execute(
        """
        SELECT count(*) AS n FROM lote
        WHERE fecha_vencimiento < CURRENT_DATE
          AND stock_disponible - stock_reservado > 0
        """
    ).fetchone()["n"]

    activos_sin_stock = conn.execute(
        """
        SELECT count(*) AS n FROM producto p
        WHERE p.activo AND NOT EXISTS (
            SELECT 1 FROM lote l
            WHERE l.producto_id = p.id AND l.stock_disponible - l.stock_reservado > 0
        )
        """
    ).fetchone()["n"]

    alertas = []
    if reservado_mayor:
        alertas.append(
            {
                "tipo": "reserva",
                "mensaje": f"{reservado_mayor} lote(s) con stock reservado mayor al disponible.",
            }
        )
    if vencidos_con_stock:
        alertas.append(
            {
                "tipo": "vencido",
                "mensaje": f"{vencidos_con_stock} lote(s) vencido(s) que todavía tienen stock.",
            }
        )
    if activos_sin_stock:
        alertas.append(
            {
                "tipo": "sin_stock",
                "mensaje": f"{activos_sin_stock} producto(s) activo(s) sin stock disponible.",
            }
        )

    disponible = int(lotes["disponible"])
    reservado = int(lotes["reservado"])

    return {
        "productos_total": productos["total"],
        "productos_activos": productos["activos"],
        "productos_ocultos": productos["ocultos"],
        "lotes_total": lotes["total"],
        "stock_disponible": disponible,
        "stock_reservado": reservado,
        "stock_neto": disponible - reservado,
        "lotes_por_vencer": lotes["por_vencer"],
        "lotes_vencidos": lotes["vencidos"],
        "valor_stock": valor["valor"],
        "por_tipo": por_tipo,
        "proximos_vencimientos": proximos,
        "alertas": alertas,
    }
