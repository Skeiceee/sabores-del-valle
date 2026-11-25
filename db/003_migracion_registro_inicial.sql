-- =====================================================================
-- HU-00 — Registro inicial de migración (staging / auditoría / reporte)
-- Opcional: ejecutar después de 002_datos_iniciales.sql.
-- Guarda las 24 filas del Excel con su estado y observaciones.
-- =====================================================================

BEGIN;

INSERT INTO migracion_registro (
    migracion_id,
    archivo_origen,
    fila_origen,
    clave_producto_lote,
    hash_fila,
    sku_origen,
    categoria_origen,
    producto_origen,
    formato_origen,
    precio_origen,
    stock_disponible_origen,
    stock_reservado_origen,
    lote_origen,
    fecha_elaboracion_origen,
    fecha_vencimiento_origen,
    tipo_producto_id,
    precio_venta,
    stock_disponible,
    stock_reservado,
    fecha_elaboracion,
    fecha_vencimiento,
    estado,
    mensaje,
    producto_id,
    lote_id
)
SELECT
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Sabores_del_Valle_Productos.xlsx',
    v.fila_origen,
    v.clave_producto_lote,
    v.hash_fila,
    v.sku_origen,
    v.categoria_origen,
    v.producto_origen,
    v.formato_origen,
    v.precio_origen,
    v.stock_disponible_origen,
    v.stock_reservado_origen,
    v.lote_origen,
    v.fecha_elaboracion_origen,
    v.fecha_vencimiento_origen,
    p.tipo_producto_id,
    v.precio_venta,
    v.stock_disponible,
    v.stock_reservado,
    v.fecha_elaboracion,
    v.fecha_vencimiento,
    v.estado,
    v.mensaje,
    p.id,
    l.id
FROM (VALUES

    (2, 'SDV-1001|LOTE-474', '081e7305485a54bfa3ff6f7643f96199de17f147278d5aa4ee86d3d8f2146fdc', 'SDV-1001', 'Mermeladas', 'Mermelada de Frambuesa Artesanal', 'Bolsa 500 g', '340', '85', '0', 'LOTE-474', '46206', '46326', 340.00, 85, 0, DATE '2026-07-03', DATE '2026-10-31', 'importada_con_alerta', 'Estado Excel ''Sin stock'' con stock disponible 85 > 0; Lote vencido al 2026-11-22 (vencimiento 2026-10-31)'),
    (3, 'SDV-1002|LOTE-346', '6970970359aa5e718061fbbb3e8a70ca2cd595f19d137fbecf90bf172c16b4b5', 'SDV-1002', 'Mermeladas', 'Mermelada de Murtilla', 'Frasco 250 g', '380', '40', '0', 'LOTE-346', '46309', '46429', 380.00, 40, 0, DATE '2026-10-14', DATE '2027-02-11', 'importada', NULL),
    (4, 'SDV-1003|LOTE-150', 'f66cf5ec9efd334f80282e60fd3d9f536a0b0323692ccfd341ade33ae02adb2b', 'SDV-1003', 'Mermeladas', 'Mermelada de Naranja Amarga', 'Bolsa 100 g', '310', '12', '0', 'LOTE-150', '46222', '46587', 310.00, 12, 0, DATE '2026-07-19', DATE '2027-07-19', 'importada', NULL),
    (5, 'SDV-1004|LOTE-684', '756dfe1eb461cc7f9e48f6fd4086c4fd1ca39f516c94aeac1321ab7a5665dc42', 'SDV-1004', 'Mermeladas', 'Mermelada de Higo con Nuez', 'Bolsa 500 g', '420', '25', '5', 'LOTE-684', '46252', '46372', 420.00, 25, 5, DATE '2026-08-18', DATE '2026-12-16', 'importada_con_alerta', 'Vence en 24 días y el estado Excel es ''Activo'''),
    (6, 'SDV-1005|LOTE-733', 'f37fae32634cfc98bb2fc9c3576c19cb15262f56a535058897fd0dbfc0d21e54', 'SDV-1005', 'Salsas', 'Salsa de Ají Verde', 'Frasco 250 g', '290', '40', '5', 'LOTE-733', '46222', '46342', 290.00, 40, 5, DATE '2026-07-19', DATE '2026-11-16', 'importada_con_alerta', 'Lote vencido al 2026-11-22 (vencimiento 2026-11-16)'),
    (7, 'SDV-1006|LOTE-354', '1cfefaeceecaa9f01a938254e92a181af3164d32f19156c52e8f3a3054a47e4c', 'SDV-1006', 'Salsas', 'Salsa de Tomate Ahumado', 'Bolsa 500 g', '300', '120', '5', 'LOTE-354', '46307', '46547', 300.00, 120, 5, DATE '2026-10-12', DATE '2027-06-09', 'importada', NULL),
    (8, 'SDV-1007|LOTE-394', '436a7f37d13ff576e42f6af952619f54e8163ed79c92fa1caf0219bd3109cbee', 'SDV-1007', 'Salsas', 'Pebre en Frasco', 'Bolsa 500 g', '270', '60', '20', 'LOTE-394', '46289', '46654', 270.00, 60, 20, DATE '2026-09-24', DATE '2027-09-24', 'importada_con_alerta', 'Estado Excel ''Sin stock'' con stock disponible 60 > 0'),
    (9, 'SDV-1008|LOTE-140', '402ad6c6c0d996666a171b523c777553449388bba7fa8e668a562c22a3f590e3', 'SDV-1008', 'Salsas', 'Salsa de Ají Rojo Picante', 'Frasco 300 g', '300', '120', '0', 'LOTE-140', '46250', '46615', 300.00, 120, 0, DATE '2026-08-16', DATE '2027-08-16', 'importada', NULL),
    (10, 'SDV-1009|LOTE-376', '8626ca0eded982510460f4b841f4c4a09793bc9270caec4b64a92c3fe1faef47', 'SDV-1009', 'Conservas', 'Tomates Secos en Aceite', 'Bolsa 500 g', '520', '85', '20', 'LOTE-376', '46298', '46418', 520.00, 85, 20, DATE '2026-10-03', DATE '2027-01-31', 'importada_con_alerta', 'Estado Excel ''Próximo a vencer'' con 70 días para vencer'),
    (11, 'SDV-1010|LOTE-784', '8e105dae6d4c5632d44dddd8e371dc526e663d0987fe99c11faf6ecad09d0d78', 'SDV-1010', 'Conservas', 'Aceitunas Verdes en Salmuera', 'Bolsa 100 g', '450', '60', '20', 'LOTE-784', '46305', '46670', 450.00, 60, 20, DATE '2026-10-10', DATE '2027-10-10', 'importada', NULL),
    (12, 'SDV-1011|LOTE-323', 'd79244c2a05e79e0bff8ff3bd867208242c72d4d265ea4437747e19495f3d75f', 'SDV-1011', 'Conservas', 'Pimentones Asados en Aceite', 'Caja 12 un.', '490', '85', '0', 'LOTE-323', '46219', '46339', 490.00, 85, 0, DATE '2026-07-16', DATE '2026-11-13', 'importada_con_alerta', 'Lote vencido al 2026-11-22 (vencimiento 2026-11-13)'),
    (13, 'SDV-1012|LOTE-511', '57dd965b46b9a2ce69d94036a17ca8838ff51a98a043884916a457f0ba4fcbe3', 'SDV-1012', 'Conservas', 'Choclos en Conserva', 'Bolsa 500 g', '400', '120', '10', 'LOTE-511', '46209', '46574', 400.00, 120, 10, DATE '2026-07-06', DATE '2027-07-06', 'importada_con_alerta', 'Estado Excel ''Sin stock'' con stock disponible 120 > 0'),
    (14, 'SDV-1013|LOTE-336', '28d7cf5a160cc4558024288c477f4ac4c6e96395c21a6bb1780d92c3aef6e154', 'SDV-1013', 'Miel', 'Miel de Ulmo 500 g', 'Frasco 300 g', '720', '120', '20', 'LOTE-336', '46307', '46672', 720.00, 120, 20, DATE '2026-10-12', DATE '2027-10-12', 'importada_con_alerta', 'Formato ''Frasco 300 g'' no coincide con el gramaje del nombre ''Miel de Ulmo 500 g'''),
    (15, 'SDV-1014|LOTE-951', '1cfbef0fddc66db77820aabf851afb9fa08b48d8e5bc0b6722f10d7a2bf11b4b', 'SDV-1014', 'Miel', 'Miel Multifloral 500 g', 'Bolsa 100 g', '680', '25', '0', 'LOTE-951', '46235', '46600', 680.00, 25, 0, DATE '2026-08-01', DATE '2027-08-01', 'importada_con_alerta', 'Estado Excel ''Sin stock'' con stock disponible 25 > 0; Formato ''Bolsa 100 g'' no coincide con el gramaje del nombre ''Miel Multifloral 500 g'''),
    (16, 'SDV-1015|LOTE-724', 'a4b41d17f305d19ac61918d7363e43ee850055c00d589ed56eda029bb2e7fc5f', 'SDV-1015', 'Miel', 'Miel de Quillay 250 g', 'Frasco 180 g', '420', '60', '0', 'LOTE-724', '46313', '46553', 420.00, 60, 0, DATE '2026-10-18', DATE '2027-06-15', 'importada_con_alerta', 'Estado Excel ''Sin stock'' con stock disponible 60 > 0; Formato ''Frasco 180 g'' no coincide con el gramaje del nombre ''Miel de Quillay 250 g'''),
    (17, 'SDV-1016|LOTE-503', '585e32ffb0709fcfc331dec9c33a0a1c07752dcb9de2367064833fe184b7d965', 'SDV-1016', 'Miel', 'Miel con Nuez 300 g', 'Bolsa 100 g', '620', '0', '10', 'LOTE-503', '46308', '46673', 620.00, 0, 10, DATE '2026-10-13', DATE '2027-10-13', 'importada_con_alerta', 'Stock reservado (10) mayor que stock disponible (0); neto -10; Estado Excel ''Activo'' con stock neto -10 <= 0; Formato ''Bolsa 100 g'' no coincide con el gramaje del nombre ''Miel con Nuez 300 g'''),
    (18, 'SDV-1017|LOTE-212', 'afea49ff9034a0621f22f4aeb5e9ad8ab3c36d581131a9513f44e9f84759aa21', 'SDV-1017', 'Galletas', 'Galletas de Avena y Miel', 'Frasco 250 g', '260', '0', '0', 'LOTE-212', '46249', '46429', 260.00, 0, 0, DATE '2026-08-15', DATE '2027-02-11', 'importada_con_alerta', 'Estado Excel ''Activo'' con stock neto 0 <= 0'),
    (19, 'SDV-1018|LOTE-172', '43bfd12edf4f4463ea8b9c6c45401ea1a6f55d20f607179983e4a96b9a1ada8f', 'SDV-1018', 'Galletas', 'Galletas de Naranja y Chocolate', 'Frasco 180 g', '290', '0', '20', 'LOTE-172', '46215', '46335', 290.00, 0, 20, DATE '2026-07-12', DATE '2026-11-09', 'importada_con_alerta', 'Stock reservado (20) mayor que stock disponible (0); neto -20; Estado Excel ''Activo'' con stock neto -20 <= 0; Lote vencido al 2026-11-22 (vencimiento 2026-11-09)'),
    (20, 'SDV-1019|LOTE-218', 'adeef9b7447404e25ea1255d1bc771723b0c2c4e076484deea84b01cd3f926ce', 'SDV-1019', 'Galletas', 'Galletas Integrales con Semillas', 'Caja 12 un.', '280', '60', '5', 'LOTE-218', '46281', '46401', 280.00, 60, 5, DATE '2026-09-16', DATE '2027-01-14', 'importada', NULL),
    (21, 'SDV-1020|LOTE-858', '96ca153d68f059fe17a6b08d8bc0edf1f03bde7bcac83c44426641563d0e5f21', 'SDV-1020', 'Galletas', 'Galletas de Almendra', 'Frasco 250 g', '310', '150', '5', 'LOTE-858', '46238', '46478', 310.00, 150, 5, DATE '2026-08-04', DATE '2027-04-01', 'importada', NULL),
    (22, 'SDV-1021|LOTE-876', '406bf15b4a3d53bbe4a71922b5ec514e6bd6b49d78fad3f4a777bef753c53915', 'SDV-1021', 'Deshidratados', 'Manzana Deshidratada 100 g', 'Caja 12 un.', '250', '0', '0', 'LOTE-876', '46270', '46390', 250.00, 0, 0, DATE '2026-09-05', DATE '2027-01-03', 'importada_con_alerta', 'Formato ''Caja 12 un.'' no coincide con el gramaje del nombre ''Manzana Deshidratada 100 g'''),
    (23, 'SDV-1022|LOTE-645', '86790e92c448cd808e01a41d728556fedd7a78eaa91e68380e54fc05b98af65c', 'SDV-1022', 'Deshidratados', 'Tomate Deshidratado 80 g', 'Frasco 300 g', '300', '60', '20', 'LOTE-645', '46246', '46426', 300.00, 60, 20, DATE '2026-08-12', DATE '2027-02-08', 'importada_con_alerta', 'Estado Excel ''Sin stock'' con stock disponible 60 > 0; Formato ''Frasco 300 g'' no coincide con el gramaje del nombre ''Tomate Deshidratado 80 g'''),
    (24, 'SDV-1023|LOTE-464', '49c649c67378a3df1cb5b0a2191316ab5e5871146f64fbbc20377b606a597a16', 'SDV-1023', 'Deshidratados', 'Frutilla Deshidratada 60 g', 'Bolsa 500 g', '360', '40', '0', 'LOTE-464', '46241', '46606', 360.00, 40, 0, DATE '2026-08-07', DATE '2027-08-07', 'importada_con_alerta', 'Formato ''Bolsa 500 g'' no coincide con el gramaje del nombre ''Frutilla Deshidratada 60 g'''),
    (25, 'SDV-1024|LOTE-473', 'ce79299f018cd248b5f14a803f9940afd1880dcc6c7cb8626920cb08e3862492', 'SDV-1024', 'Deshidratados', 'Mix de Frutas Deshidratadas 150 g', 'Frasco 180 g', '420', '150', '5', 'LOTE-473', '46280', '46520', 420.00, 150, 5, DATE '2026-09-15', DATE '2027-05-13', 'importada_con_alerta', 'Formato ''Frasco 180 g'' no coincide con el gramaje del nombre ''Mix de Frutas Deshidratadas 150 g''')
) AS v(
    fila_origen,
    clave_producto_lote,
    hash_fila,
    sku_origen,
    categoria_origen,
    producto_origen,
    formato_origen,
    precio_origen,
    stock_disponible_origen,
    stock_reservado_origen,
    lote_origen,
    fecha_elaboracion_origen,
    fecha_vencimiento_origen,
    precio_venta,
    stock_disponible,
    stock_reservado,
    fecha_elaboracion,
    fecha_vencimiento,
    estado,
    mensaje
)
JOIN producto p ON p.sku = v.sku_origen
JOIN lote l ON l.producto_id = p.id AND l.codigo = v.lote_origen
ON CONFLICT (migracion_id, fila_origen) DO NOTHING;

COMMIT;

-- Verificación esperada:
-- total = 24, importadas + importadas_con_alerta = 24,
-- pendientes = 0, errores = 0, duplicadas = 0.
SELECT estado, count(*) AS filas
FROM migracion_registro
WHERE migracion_id = '11111111-1111-1111-1111-111111111111'::uuid
GROUP BY estado
ORDER BY estado;
