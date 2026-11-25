-- =====================================================================
-- HU-00 — Datos iniciales desde Sabores_del_Valle_Productos.xlsx
-- Ejecutar después de 001_esquema.sql.
-- 24 productos, 24 lotes, 1.517 unidades disponibles y 170 reservadas.
-- Es idempotente: no duplica productos ni lotes si se ejecuta de nuevo.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- Tipos de producto (idempotente; también están en 001_esquema.sql)
-- ---------------------------------------------------------------------
INSERT INTO tipo_producto (nombre) VALUES
    ('Mermeladas'),
    ('Salsas'),
    ('Conservas'),
    ('Miel'),
    ('Galletas'),
    ('Productos deshidratados')
ON CONFLICT (nombre) DO NOTHING;

-- ---------------------------------------------------------------------
-- Productos
-- ---------------------------------------------------------------------
INSERT INTO producto (sku, tipo_producto_id, nombre, formato, precio_venta)
SELECT v.sku, tp.id, v.nombre, v.formato, v.precio_venta
FROM (VALUES

    ('SDV-1001', 'Mermeladas', 'Mermelada de Frambuesa Artesanal', 'Bolsa 500 g', 340.00),
    ('SDV-1002', 'Mermeladas', 'Mermelada de Murtilla', 'Frasco 250 g', 380.00),
    ('SDV-1003', 'Mermeladas', 'Mermelada de Naranja Amarga', 'Bolsa 100 g', 310.00),
    ('SDV-1004', 'Mermeladas', 'Mermelada de Higo con Nuez', 'Bolsa 500 g', 420.00),
    ('SDV-1005', 'Salsas', 'Salsa de Ají Verde', 'Frasco 250 g', 290.00),
    ('SDV-1006', 'Salsas', 'Salsa de Tomate Ahumado', 'Bolsa 500 g', 300.00),
    ('SDV-1007', 'Salsas', 'Pebre en Frasco', 'Bolsa 500 g', 270.00),
    ('SDV-1008', 'Salsas', 'Salsa de Ají Rojo Picante', 'Frasco 300 g', 300.00),
    ('SDV-1009', 'Conservas', 'Tomates Secos en Aceite', 'Bolsa 500 g', 520.00),
    ('SDV-1010', 'Conservas', 'Aceitunas Verdes en Salmuera', 'Bolsa 100 g', 450.00),
    ('SDV-1011', 'Conservas', 'Pimentones Asados en Aceite', 'Caja 12 un.', 490.00),
    ('SDV-1012', 'Conservas', 'Choclos en Conserva', 'Bolsa 500 g', 400.00),
    ('SDV-1013', 'Miel', 'Miel de Ulmo 500 g', 'Frasco 300 g', 720.00),
    ('SDV-1014', 'Miel', 'Miel Multifloral 500 g', 'Bolsa 100 g', 680.00),
    ('SDV-1015', 'Miel', 'Miel de Quillay 250 g', 'Frasco 180 g', 420.00),
    ('SDV-1016', 'Miel', 'Miel con Nuez 300 g', 'Bolsa 100 g', 620.00),
    ('SDV-1017', 'Galletas', 'Galletas de Avena y Miel', 'Frasco 250 g', 260.00),
    ('SDV-1018', 'Galletas', 'Galletas de Naranja y Chocolate', 'Frasco 180 g', 290.00),
    ('SDV-1019', 'Galletas', 'Galletas Integrales con Semillas', 'Caja 12 un.', 280.00),
    ('SDV-1020', 'Galletas', 'Galletas de Almendra', 'Frasco 250 g', 310.00),
    ('SDV-1021', 'Productos deshidratados', 'Manzana Deshidratada 100 g', 'Caja 12 un.', 250.00),
    ('SDV-1022', 'Productos deshidratados', 'Tomate Deshidratado 80 g', 'Frasco 300 g', 300.00),
    ('SDV-1023', 'Productos deshidratados', 'Frutilla Deshidratada 60 g', 'Bolsa 500 g', 360.00),
    ('SDV-1024', 'Productos deshidratados', 'Mix de Frutas Deshidratadas 150 g', 'Frasco 180 g', 420.00)
) AS v(sku, tipo, nombre, formato, precio_venta)
JOIN tipo_producto tp ON tp.nombre = v.tipo
ON CONFLICT (sku) DO NOTHING;

-- ---------------------------------------------------------------------
-- Lotes y stock
-- ---------------------------------------------------------------------
INSERT INTO lote (producto_id, codigo, fecha_elaboracion, fecha_vencimiento, stock_disponible, stock_reservado)
SELECT p.id, v.codigo, v.fecha_elaboracion, v.fecha_vencimiento, v.stock_disponible, v.stock_reservado
FROM (VALUES

    ('SDV-1001', 'LOTE-474', DATE '2026-07-03', DATE '2026-10-31', 85, 0),
    ('SDV-1002', 'LOTE-346', DATE '2026-10-14', DATE '2027-02-11', 40, 0),
    ('SDV-1003', 'LOTE-150', DATE '2026-07-19', DATE '2027-07-19', 12, 0),
    ('SDV-1004', 'LOTE-684', DATE '2026-08-18', DATE '2026-12-16', 25, 5),
    ('SDV-1005', 'LOTE-733', DATE '2026-07-19', DATE '2026-11-16', 40, 5),
    ('SDV-1006', 'LOTE-354', DATE '2026-10-12', DATE '2027-06-09', 120, 5),
    ('SDV-1007', 'LOTE-394', DATE '2026-09-24', DATE '2027-09-24', 60, 20),
    ('SDV-1008', 'LOTE-140', DATE '2026-08-16', DATE '2027-08-16', 120, 0),
    ('SDV-1009', 'LOTE-376', DATE '2026-10-03', DATE '2027-01-31', 85, 20),
    ('SDV-1010', 'LOTE-784', DATE '2026-10-10', DATE '2027-10-10', 60, 20),
    ('SDV-1011', 'LOTE-323', DATE '2026-07-16', DATE '2026-11-13', 85, 0),
    ('SDV-1012', 'LOTE-511', DATE '2026-07-06', DATE '2027-07-06', 120, 10),
    ('SDV-1013', 'LOTE-336', DATE '2026-10-12', DATE '2027-10-12', 120, 20),
    ('SDV-1014', 'LOTE-951', DATE '2026-08-01', DATE '2027-08-01', 25, 0),
    ('SDV-1015', 'LOTE-724', DATE '2026-10-18', DATE '2027-06-15', 60, 0),
    ('SDV-1016', 'LOTE-503', DATE '2026-10-13', DATE '2027-10-13', 0, 10),
    ('SDV-1017', 'LOTE-212', DATE '2026-08-15', DATE '2027-02-11', 0, 0),
    ('SDV-1018', 'LOTE-172', DATE '2026-07-12', DATE '2026-11-09', 0, 20),
    ('SDV-1019', 'LOTE-218', DATE '2026-09-16', DATE '2027-01-14', 60, 5),
    ('SDV-1020', 'LOTE-858', DATE '2026-08-04', DATE '2027-04-01', 150, 5),
    ('SDV-1021', 'LOTE-876', DATE '2026-09-05', DATE '2027-01-03', 0, 0),
    ('SDV-1022', 'LOTE-645', DATE '2026-08-12', DATE '2027-02-08', 60, 20),
    ('SDV-1023', 'LOTE-464', DATE '2026-08-07', DATE '2027-08-07', 40, 0),
    ('SDV-1024', 'LOTE-473', DATE '2026-09-15', DATE '2027-05-13', 150, 5)
) AS v(sku, codigo, fecha_elaboracion, fecha_vencimiento, stock_disponible, stock_reservado)
JOIN producto p ON p.sku = v.sku
ON CONFLICT (producto_id, codigo) DO NOTHING;

COMMIT;

-- Verificación esperada:
-- tipos = 6, productos = 24, lotes = 24,
-- stock_disponible = 1517, stock_reservado = 170.
SELECT
    (SELECT count(*) FROM tipo_producto) AS tipos,
    (SELECT count(*) FROM producto) AS productos,
    (SELECT count(*) FROM lote) AS lotes,
    (SELECT COALESCE(sum(stock_disponible), 0) FROM lote) AS stock_disponible,
    (SELECT COALESCE(sum(stock_reservado), 0) FROM lote) AS stock_reservado;
