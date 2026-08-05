-- ══════════════════════════════════════════
-- RetailChain — UNION y UNION ALL
-- Autor: Bruno
-- Fecha: 05/08/2026
-- Motor: SQL Server
-- ══════════════════════════════════════════


-- ── CONSULTA 1: UNION ────────────────────
-- Reporte de Catálogo Unificado
-- Pregunta de negocio: ¿Qué productos únicos comercializa
-- la empresa en toda su red de sucursales?
-- Operador: UNION (elimina filas completamente duplicadas)
--
-- La columna stock se excluye deliberadamente del SELECT: el catálogo
-- comercial responde qué se comercializa, no cuánto hay en depósito.
-- Incluirla haría que los productos presentes en ambas sucursales dejaran
-- de ser filas idénticas (tienen stock distinto en cada una) y UNION no
-- los deduplicaría.
SELECT
    id_producto,
    nombre_producto,
    categoria
FROM inventario_sucursal_norte
UNION
SELECT
    id_producto,
    nombre_producto,
    categoria
FROM inventario_sucursal_sur
ORDER BY id_producto;


-- ── CONSULTA 2: UNION ALL ────────────────
-- Auditoría de Stock Total
-- Pregunta de negocio: ¿Cuántos registros físicos de stock
-- existen en total entre ambas sucursales?
-- Operador: UNION ALL (mantiene todos los registros incluyendo duplicados)
--
-- Aquí sí se incluye stock: la auditoría operativa necesita la existencia
-- física declarada por cada sucursal, no un catálogo depurado.
SELECT
    id_producto,
    nombre_producto,
    categoria,
    stock
FROM inventario_sucursal_norte
UNION ALL
SELECT
    id_producto,
    nombre_producto,
    categoria,
    stock
FROM inventario_sucursal_sur
ORDER BY id_producto;


-- ── CONSULTA 3: COMPARACIÓN DE RESULTADOS ─
-- Cantidad de filas devueltas por cada operador.
-- El ORDER BY se omite dentro de las subconsultas: no es válido allí
-- y resulta irrelevante para un conteo.
SELECT COUNT(*) AS filas_union
FROM (
    SELECT
        id_producto,
        nombre_producto,
        categoria
    FROM inventario_sucursal_norte
    UNION
    SELECT
        id_producto,
        nombre_producto,
        categoria
    FROM inventario_sucursal_sur
) AS resultado_union;

SELECT COUNT(*) AS filas_union_all
FROM (
    SELECT
        id_producto,
        nombre_producto,
        categoria,
        stock
    FROM inventario_sucursal_norte
    UNION ALL
    SELECT
        id_producto,
        nombre_producto,
        categoria,
        stock
    FROM inventario_sucursal_sur
) AS resultado_union_all;
