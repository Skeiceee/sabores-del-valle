from fastapi import APIRouter, Depends, Header, HTTPException, Query
from psycopg import errors

from ..db import Conn, registrar_auditoria
from ..schemas import (
    CambioEstado,
    ProductoCrear,
    ProductoEditar,
    ProductoOut,
    TipoProductoOut,
)

router = APIRouter(prefix="/api", tags=["productos"])

PRODUCTO_SELECT = """
SELECT
    p.id,
    p.sku,
    p.tipo_producto_id,
    t.nombre AS tipo_producto,
    p.nombre,
    p.formato,
    p.precio_venta::float8 AS precio_venta,
    p.descripcion,
    p.ingredientes,
    p.alergenos,
    p.activo,
    p.created_at,
    p.updated_at,
    COALESCE(a.lotes, 0) AS lotes,
    COALESCE(a.stock_disponible, 0) AS stock_disponible,
    COALESCE(a.stock_reservado, 0) AS stock_reservado,
    COALESCE(a.stock_disponible, 0) - COALESCE(a.stock_reservado, 0) AS stock_neto,
    a.proximo_vencimiento
FROM producto p
JOIN tipo_producto t ON t.id = p.tipo_producto_id
LEFT JOIN (
    SELECT
        producto_id,
        count(*) AS lotes,
        sum(stock_disponible) AS stock_disponible,
        sum(stock_reservado) AS stock_reservado,
        min(fecha_vencimiento) FILTER (WHERE fecha_vencimiento >= CURRENT_DATE) AS proximo_vencimiento
    FROM lote
    GROUP BY producto_id
) a ON a.producto_id = p.id
"""


def _obtener(conn, producto_id: int) -> dict | None:
    return conn.execute(
        PRODUCTO_SELECT + " WHERE p.id = %s", (producto_id,)
    ).fetchone()


def _campos_auditoria(row: dict) -> dict:
    return {
        "sku": row["sku"],
        "nombre": row["nombre"],
        "tipo_producto_id": row["tipo_producto_id"],
        "tipo_producto": row["tipo_producto"],
        "formato": row["formato"],
        "precio_venta": row["precio_venta"],
        "descripcion": row["descripcion"],
        "ingredientes": row["ingredientes"],
        "alergenos": row["alergenos"],
        "activo": row["activo"],
    }


def _detalle_cambios(antes: dict, despues: dict) -> str:
    etiquetas = {
        "sku": "SKU",
        "nombre": "nombre",
        "tipo_producto_id": "categoría",
        "formato": "formato",
        "precio_venta": "precio",
        "descripcion": "descripción",
        "ingredientes": "ingredientes",
        "alergenos": "alérgenos",
    }
    cambios = [
        etiquetas[campo]
        for campo, etiqueta in etiquetas.items()
        if antes.get(campo) != despues.get(campo)
    ]
    return "Campos modificados: " + ", ".join(cambios) if cambios else "Sin cambios de datos"


@router.get("/tipos", response_model=list[TipoProductoOut])
def listar_tipos(conn=Conn):
    return conn.execute(
        "SELECT id, nombre FROM tipo_producto WHERE activo ORDER BY nombre"
    ).fetchall()


@router.get("/productos", response_model=list[ProductoOut])
def listar_productos(
    conn=Conn,
    buscar: str | None = None,
    tipo_producto_id: int | None = None,
    estado: str = Query("todos", pattern="^(todos|activos|ocultos)$"),
):
    condiciones = []
    params: list = []

    if buscar:
        condiciones.append("(p.nombre ILIKE %s OR p.sku ILIKE %s OR p.descripcion ILIKE %s)")
        patron = f"%{buscar.strip()}%"
        params.extend([patron, patron, patron])

    if tipo_producto_id:
        condiciones.append("p.tipo_producto_id = %s")
        params.append(tipo_producto_id)

    if estado == "activos":
        condiciones.append("p.activo")
    elif estado == "ocultos":
        condiciones.append("NOT p.activo")

    where = f" WHERE {' AND '.join(condiciones)}" if condiciones else ""
    return conn.execute(
        PRODUCTO_SELECT + where + " ORDER BY p.activo DESC, p.nombre", params
    ).fetchall()


@router.get("/productos/{producto_id}", response_model=ProductoOut)
def obtener_producto(producto_id: int, conn=Conn):
    row = _obtener(conn, producto_id)
    if not row:
        raise HTTPException(404, "Producto no encontrado")
    return row


@router.post("/productos", response_model=ProductoOut, status_code=201)
def crear_producto(
    datos: ProductoCrear,
    conn=Conn,
    x_usuario: str = Header(default="admin", alias="X-Usuario"),
):
    try:
        with conn.transaction():
            row = conn.execute(
                """
                INSERT INTO producto
                    (sku, tipo_producto_id, nombre, formato, precio_venta,
                     descripcion, ingredientes, alergenos)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
                """,
                (
                    datos.sku,
                    datos.tipo_producto_id,
                    datos.nombre,
                    datos.formato,
                    datos.precio_venta,
                    datos.descripcion,
                    datos.ingredientes,
                    datos.alergenos,
                ),
            ).fetchone()
            creado = _obtener(conn, row["id"])
            registrar_auditoria(
                conn,
                row["id"],
                "crear",
                x_usuario,
                detalle=f"Producto creado: {datos.nombre}",
                despues=_campos_auditoria(creado),
            )
    except errors.UniqueViolation:
        raise HTTPException(409, f"Ya existe un producto con el SKU {datos.sku}")
    except errors.ForeignKeyViolation:
        raise HTTPException(400, "La categoría indicada no existe")
    return creado


@router.put("/productos/{producto_id}", response_model=ProductoOut)
def editar_producto(
    producto_id: int,
    datos: ProductoEditar,
    conn=Conn,
    x_usuario: str = Header(default="admin", alias="X-Usuario"),
):
    try:
        with conn.transaction():
            antes = _obtener(conn, producto_id)
            if not antes:
                raise HTTPException(404, "Producto no encontrado")

            conn.execute(
                """
                UPDATE producto SET
                    sku = %s,
                    tipo_producto_id = %s,
                    nombre = %s,
                    formato = %s,
                    precio_venta = %s,
                    descripcion = %s,
                    ingredientes = %s,
                    alergenos = %s,
                    updated_at = now()
                WHERE id = %s
                """,
                (
                    datos.sku,
                    datos.tipo_producto_id,
                    datos.nombre,
                    datos.formato,
                    datos.precio_venta,
                    datos.descripcion,
                    datos.ingredientes,
                    datos.alergenos,
                    producto_id,
                ),
            )
            despues = _obtener(conn, producto_id)
            registrar_auditoria(
                conn,
                producto_id,
                "editar",
                x_usuario,
                detalle=_detalle_cambios(_campos_auditoria(antes), _campos_auditoria(despues)),
                antes=_campos_auditoria(antes),
                despues=_campos_auditoria(despues),
            )
    except errors.UniqueViolation:
        raise HTTPException(409, f"Ya existe un producto con el SKU {datos.sku}")
    except errors.ForeignKeyViolation:
        raise HTTPException(400, "La categoría indicada no existe")
    return despues


@router.patch("/productos/{producto_id}/estado", response_model=ProductoOut)
def cambiar_estado(
    producto_id: int,
    datos: CambioEstado,
    conn=Conn,
    x_usuario: str = Header(default="admin", alias="X-Usuario"),
):
    with conn.transaction():
        antes = _obtener(conn, producto_id)
        if not antes:
            raise HTTPException(404, "Producto no encontrado")

        if antes["activo"] != datos.activo:
            conn.execute(
                "UPDATE producto SET activo = %s, updated_at = now() WHERE id = %s",
                (datos.activo, producto_id),
            )
            despues = _obtener(conn, producto_id)
            registrar_auditoria(
                conn,
                producto_id,
                "reactivar" if datos.activo else "ocultar",
                x_usuario,
                detalle=(
                    "Producto visible en el catálogo público"
                    if datos.activo
                    else "Producto oculto del catálogo público (sin borrar historial)"
                ),
                antes={"activo": antes["activo"]},
                despues={"activo": despues["activo"]},
            )
        else:
            despues = antes

    return despues


@router.get("/productos/{producto_id}/auditoria")
def auditoria_producto(producto_id: int, conn=Conn, limite: int = Query(50, ge=1, le=200)):
    return conn.execute(
        """
        SELECT id, producto_id, accion, usuario, detalle, fecha,
               datos_anteriores, datos_nuevos
        FROM producto_auditoria
        WHERE producto_id = %s
        ORDER BY fecha DESC, id DESC
        LIMIT %s
        """,
        (producto_id, limite),
    ).fetchall()
