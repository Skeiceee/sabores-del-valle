-- =====================================================================
-- HU-00 — Migración de stock y tipo de producto
-- Esquema MVP: 4 tablas, sin vistas, sin procedimientos, sin triggers.
-- Motor: PostgreSQL 13+
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Tipos de producto
-- ---------------------------------------------------------------------
CREATE TABLE tipo_producto (
    id          smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre      varchar(60) NOT NULL UNIQUE,
    activo      boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 2. Productos
-- ---------------------------------------------------------------------
CREATE TABLE producto (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku               varchar(30) NOT NULL UNIQUE,
    tipo_producto_id  smallint NOT NULL REFERENCES tipo_producto(id) ON DELETE RESTRICT,
    nombre            varchar(150) NOT NULL,
    formato           varchar(80),
    precio_venta      numeric(10,2) CHECK (precio_venta IS NULL OR precio_venta >= 0),
    activo            boolean NOT NULL DEFAULT true,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 3. Lotes y stock por lote
--    El stock neto NO se almacena: se calcula como
--    stock_disponible - stock_reservado.
-- ---------------------------------------------------------------------
CREATE TABLE lote (
    id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    producto_id        bigint NOT NULL REFERENCES producto(id) ON DELETE RESTRICT,
    codigo             varchar(50) NOT NULL,
    fecha_elaboracion  date,
    fecha_vencimiento  date,
    stock_disponible   integer NOT NULL DEFAULT 0 CHECK (stock_disponible >= 0),
    stock_reservado    integer NOT NULL DEFAULT 0 CHECK (stock_reservado >= 0),
    created_at         timestamptz NOT NULL DEFAULT now(),
    updated_at         timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_lote_producto_codigo UNIQUE (producto_id, codigo),
    CONSTRAINT ck_lote_fechas CHECK (
        fecha_elaboracion IS NULL
        OR fecha_vencimiento IS NULL
        OR fecha_vencimiento >= fecha_elaboracion
    )
);

-- ---------------------------------------------------------------------
-- 4. Staging, auditoría y reporte de migración
--    Es permisiva a propósito: guarda datos crudos y parseados aunque
--    sean inválidos, para poder reportarlos y corregirlos.
-- ---------------------------------------------------------------------
CREATE TABLE migracion_registro (
    id                          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    migracion_id                uuid NOT NULL,
    archivo_origen              varchar(255) NOT NULL,
    fila_origen                 integer NOT NULL,
    clave_producto_lote         varchar(100) NOT NULL,
    hash_fila                   char(64) NOT NULL,

    -- Datos crudos tal como vienen del Excel
    sku_origen                  varchar(30),
    categoria_origen            varchar(80),
    producto_origen             varchar(150),
    formato_origen              varchar(80),
    precio_origen               varchar(30),
    stock_disponible_origen     varchar(30),
    stock_reservado_origen      varchar(30),
    lote_origen                 varchar(50),
    fecha_elaboracion_origen    varchar(30),
    fecha_vencimiento_origen    varchar(30),

    -- Datos normalizados/parseados para validar y corregir
    tipo_producto_id            smallint REFERENCES tipo_producto(id) ON DELETE SET NULL,
    precio_venta                numeric(10,2),
    stock_disponible            integer,
    stock_reservado             integer,
    fecha_elaboracion           date,
    fecha_vencimiento           date,

    estado                      varchar(30) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN (
            'pendiente',
            'lista',
            'importada',
            'importada_con_alerta',
            'error',
            'duplicada',
            'corregida'
        )),
    mensaje                     text,

    producto_id                 bigint REFERENCES producto(id) ON DELETE SET NULL,
    lote_id                     bigint REFERENCES lote(id) ON DELETE SET NULL,

    revisado_por                varchar(100),
    revisado_en                 timestamptz,

    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_migracion_fila UNIQUE (migracion_id, fila_origen)
);

-- ---------------------------------------------------------------------
-- Índices para consultas de stock, vencimientos y reporte
-- ---------------------------------------------------------------------
CREATE INDEX idx_producto_tipo
    ON producto (tipo_producto_id);

CREATE INDEX idx_lote_producto
    ON lote (producto_id);

CREATE INDEX idx_lote_vencimiento
    ON lote (fecha_vencimiento);

CREATE INDEX idx_migracion_run_estado
    ON migracion_registro (migracion_id, estado);

CREATE INDEX idx_migracion_clave
    ON migracion_registro (clave_producto_lote);

CREATE INDEX idx_migracion_producto
    ON migracion_registro (producto_id);

-- ---------------------------------------------------------------------
-- Seeds: tipos de producto
-- ---------------------------------------------------------------------
INSERT INTO tipo_producto (nombre) VALUES
    ('Mermeladas'),
    ('Salsas'),
    ('Conservas'),
    ('Miel'),
    ('Galletas'),
    ('Productos deshidratados')
ON CONFLICT (nombre) DO NOTHING;

COMMIT;
