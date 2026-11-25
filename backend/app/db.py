import json
from datetime import date, datetime
from decimal import Decimal

from fastapi import Depends
from psycopg.rows import dict_row
from psycopg.types.json import Jsonb
from psycopg_pool import ConnectionPool

from .config import DATABASE_URL

pool = ConnectionPool(
    DATABASE_URL,
    min_size=1,
    max_size=6,
    kwargs={"row_factory": dict_row},
    open=False,
)


def open_pool() -> None:
    if pool.closed:
        pool.open()


def close_pool() -> None:
    if not pool.closed:
        pool.close()


def get_conn():
    with pool.connection() as conn:
        yield conn


Conn = Depends(get_conn)


def _json_default(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    return str(value)


def to_jsonb(value) -> Jsonb:
    return Jsonb(value, dumps=lambda obj: json.dumps(obj, ensure_ascii=False, default=_json_default))


def registrar_auditoria(
    conn,
    producto_id: int,
    accion: str,
    usuario: str,
    detalle: str | None = None,
    antes=None,
    despues=None,
) -> None:
    conn.execute(
        """
        INSERT INTO producto_auditoria
            (producto_id, accion, usuario, detalle, datos_anteriores, datos_nuevos)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (
            producto_id,
            accion,
            usuario,
            detalle,
            to_jsonb(antes) if antes is not None else None,
            to_jsonb(despues) if despues is not None else None,
        ),
    )
