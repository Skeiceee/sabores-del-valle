-- =====================================================================
-- HU-03 — Administración de productos (MVP)
-- Agrega información descriptiva al producto y una tabla de auditoría.
-- Total: 5 tablas. Sin vistas, sin procedimientos, sin triggers.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Información descriptiva del producto (HU-03)
-- ---------------------------------------------------------------------
ALTER TABLE producto
    ADD COLUMN IF NOT EXISTS descripcion  text,
    ADD COLUMN IF NOT EXISTS ingredientes text,
    ADD COLUMN IF NOT EXISTS alergenos   text;

COMMENT ON COLUMN producto.descripcion  IS 'Descripción comercial del producto';
COMMENT ON COLUMN producto.ingredientes IS 'Ingredientes declarados';
COMMENT ON COLUMN producto.alergenos    IS 'Alérgenos declarados';

-- ---------------------------------------------------------------------
-- 2. Auditoría de acciones sobre productos
--    No se borra historial: el producto se oculta con producto.activo.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS producto_auditoria (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    producto_id       bigint NOT NULL REFERENCES producto(id) ON DELETE RESTRICT,
    accion            varchar(20) NOT NULL
        CHECK (accion IN ('crear', 'editar', 'ocultar', 'reactivar')),
    usuario           varchar(100) NOT NULL DEFAULT 'admin',
    detalle           text,
    datos_anteriores  jsonb,
    datos_nuevos      jsonb,
    fecha             timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_producto_auditoria_producto
    ON producto_auditoria (producto_id, fecha DESC);

CREATE INDEX IF NOT EXISTS idx_producto_auditoria_fecha
    ON producto_auditoria (fecha DESC);

COMMENT ON TABLE producto_auditoria IS
    'Registro de quién, cuándo y qué acción ejecutó sobre cada producto';

COMMIT;
