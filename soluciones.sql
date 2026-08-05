-- ══════════════════════════════════════════
-- MiniStore — Soluciones con Outer JOINs
-- Autor: Bruno
-- Fecha: 05/08/2026
-- Motor: SQL Server
-- ══════════════════════════════════════════


-- ── CONSULTA 1: LEFT JOIN ─────────────────
-- Pregunta de negocio: ¿Qué productos del catálogo nunca fueron vendidos?
-- Mostrá todos los productos y sus ventas asociadas.
-- Los productos sin ventas aparecerán con NULL en las columnas de ventas.

-- 1.a — Vista completa: los 9 productos del catálogo con sus ventas asociadas.
-- Los productos 108 y 109 aparecen con NULL en las columnas de ventas.
SELECT
    p.producto_id,
    p.nombre,
    p.categoria,
    p.precio,
    v.venta_id,
    v.cantidad,
    v.fecha_venta
FROM productos p
LEFT JOIN ventas v
    ON p.producto_id = v.producto_id
ORDER BY p.producto_id, v.venta_id;

-- 1.b — Respuesta aislada: únicamente los productos que nunca se vendieron.
-- El filtro se aplica sobre venta_id, clave primaria de ventas: al no admitir
-- NULL en la tabla original, un NULL aquí solo puede provenir del JOIN sin
-- coincidencia.
SELECT
    p.producto_id,
    p.nombre,
    p.categoria,
    p.precio,
    v.venta_id,
    v.cantidad,
    v.fecha_venta
FROM productos p
LEFT JOIN ventas v
    ON p.producto_id = v.producto_id
WHERE v.venta_id IS NULL
ORDER BY p.producto_id;


-- ── CONSULTA 2: RIGHT JOIN ────────────────
-- Pregunta de negocio: ¿Existen ventas registradas con productos
-- que no figuran en nuestro catálogo? (posible error de carga de datos)
-- Los registros huérfanos aparecerán con NULL en las columnas de productos.

-- 2.a — Vista completa: las 10 ventas registradas con los datos de catálogo.
-- La venta 10 (producto_id = 999) aparece con NULL en las columnas de productos.
SELECT
    v.venta_id,
    v.producto_id AS producto_id_venta,
    v.cliente_id,
    v.cantidad,
    v.fecha_venta,
    p.nombre      AS nombre_producto,
    p.categoria
FROM productos p
RIGHT JOIN ventas v
    ON p.producto_id = v.producto_id
ORDER BY v.venta_id;

-- 2.b — Respuesta aislada: únicamente las ventas huérfanas.
-- El filtro se aplica sobre producto_id de productos, su clave primaria:
-- un NULL en esa columna indica que la venta no encontró coincidencia
-- en el catálogo.
SELECT
    v.venta_id,
    v.producto_id AS producto_id_venta,
    v.cliente_id,
    v.cantidad,
    v.fecha_venta,
    p.nombre      AS nombre_producto,
    p.categoria
FROM productos p
RIGHT JOIN ventas v
    ON p.producto_id = v.producto_id
WHERE p.producto_id IS NULL
ORDER BY v.venta_id;


-- ── CONSULTA 3: FULL OUTER JOIN ───────────
-- Pregunta de negocio: Vista completa de auditoría que muestre
-- todos los productos y todas las ventas sin perder ninguna fila,
-- identificando tanto productos sin ventas como ventas sin producto.

-- 3.a — Vista de auditoría completa: ninguna fila de ninguna de las dos
-- tablas queda fuera del resultado.
SELECT
    p.producto_id AS producto_id_catalogo,
    p.nombre,
    p.categoria,
    p.precio,
    v.venta_id,
    v.producto_id AS producto_id_venta,
    v.cantidad,
    v.fecha_venta
FROM productos p
FULL OUTER JOIN ventas v
    ON p.producto_id = v.producto_id
ORDER BY p.producto_id, v.venta_id;

-- 3.b — Respuesta aislada: las dos anomalías del dataset en una sola salida
-- (productos sin ventas y ventas sin producto).
SELECT
    p.producto_id AS producto_id_catalogo,
    p.nombre,
    p.categoria,
    p.precio,
    v.venta_id,
    v.producto_id AS producto_id_venta,
    v.cantidad,
    v.fecha_venta
FROM productos p
FULL OUTER JOIN ventas v
    ON p.producto_id = v.producto_id
WHERE p.producto_id IS NULL
   OR v.venta_id IS NULL
ORDER BY p.producto_id, v.venta_id;
