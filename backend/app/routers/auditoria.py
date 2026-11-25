from fastapi import APIRouter, Query

from ..db import Conn
from ..schemas import AuditoriaOut

router = APIRouter(prefix="/api/auditoria", tags=["auditoría"])


@router.get("", response_model=list[AuditoriaOut])
def listar_auditoria(conn=Conn, limite: int = Query(100, ge=1, le=500)):
    return conn.execute(
        """
        SELECT a.id, a.producto_id, p.sku, p.nombre AS producto,
               a.accion, a.usuario, a.detalle, a.fecha
        FROM producto_auditoria a
        JOIN producto p ON p.id = a.producto_id
        ORDER BY a.fecha DESC, a.id DESC
        LIMIT %s
        """,
        (limite,),
    ).fetchall()
