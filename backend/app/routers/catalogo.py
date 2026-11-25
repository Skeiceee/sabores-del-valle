from fastapi import APIRouter

from ..db import Conn
from ..schemas import ProductoOut
from .productos import PRODUCTO_SELECT

router = APIRouter(prefix="/api/catalogo", tags=["catálogo público"])


@router.get("", response_model=list[ProductoOut])
def catalogo(conn=Conn, buscar: str | None = None, tipo_producto_id: int | None = None):
    """Catálogo público: solo productos activos. Refleja los cambios al instante."""
    condiciones = ["p.activo"]
    params: list = []

    if buscar:
        patron = f"%{buscar.strip()}%"
        condiciones.append("(p.nombre ILIKE %s OR p.descripcion ILIKE %s)")
        params.extend([patron, patron])

    if tipo_producto_id:
        condiciones.append("p.tipo_producto_id = %s")
        params.append(tipo_producto_id)

    return conn.execute(
        PRODUCTO_SELECT
        + " WHERE "
        + " AND ".join(condiciones)
        + " ORDER BY t.nombre, p.nombre",
        params,
    ).fetchall()
