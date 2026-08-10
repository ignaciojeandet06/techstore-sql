-- =====================================================================
-- m5_consultas_joins.sql
-- Proyecto integrador RetailPro — Módulo 5: Pre-entrega evaluable
-- Cruzando tablas para enriquecer el análisis (INNER JOIN, LEFT JOIN, UNION ALL)
--
-- Motor: SQL Server (T-SQL)
-- Requiere haber corrido antes m5_00_migracion_esquema.sql, que agrega
-- la tabla territorios y las columnas segmento (clientes) y canal
-- (ventas) al esquema simplificado de M3.
-- =====================================================================


-- =====================================================================
-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- =====================================================================

SELECT
    v.fecha_venta,
    c.nombre                           AS nombre_cliente,
    c.segmento,
    t.region,
    p.nombre_producto,
    cat.nombre_categoria               AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario)   AS total_venta,
    v.canal
FROM ventas v
INNER JOIN clientes c     ON v.id_cliente = c.id_cliente
INNER JOIN productos p    ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
INNER JOIN territorios t  ON v.id_territorio = t.id_territorio
ORDER BY v.fecha_venta;


-- =====================================================================
-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- Clientes registrados que todavía no compraron nada (interés de CRM).
-- =====================================================================

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- =====================================================================
-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Productos del catálogo sin ningún movimiento (interés de Producto).
-- =====================================================================

SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v       ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


-- =====================================================================
-- Consulta 4 — Consolidado por canal (UNION ALL)
-- Apila las ventas Online y Presencial en un único resultado, con
-- columna canal, y calcula el total facturado por canal.
-- =====================================================================

SELECT
    canal,
    SUM(cantidad * precio_unitario) AS total_por_canal
FROM (
    SELECT cantidad, precio_unitario, canal
    FROM ventas
    WHERE canal = 'Online'

    UNION ALL

    SELECT cantidad, precio_unitario, canal
    FROM ventas
    WHERE canal = 'Presencial'
) AS ventas_por_canal
GROUP BY canal;


-- =====================================================================
-- Hallazgos (resultados reales al ejecutar las 4 consultas de arriba
-- sobre Ventas_Tech_DB, luego de aplicar m5_00_migracion_esquema.sql)
-- =====================================================================
-- 1. La vista base (Consulta 1) enriquece las 10 ventas de M3 con
--    cliente, segmento, región, producto y categoría en una sola fila
--    cada una: es la tabla que se va a conectar directo a Power BI.
-- 2. Consulta 2 detecta 1 cliente sin compras (Sofía Medina, alta
--    2024-04-01) — el CRM puede usar esta lista para campañas de
--    primer contacto.
-- 3. Consulta 3 detecta 1 producto sin ventas (Webcam HD, categoría
--    Accesorios) — candidato a revisar en el catálogo o en una
--    promoción de lanzamiento.
-- 4. Consulta 4 muestra que el canal Online concentra $ 4.560,00 frente
--    a $ 1.884,00 del canal Presencial: casi el 71% de la facturación
--    del período pasa por el canal digital.
-- =====================================================================
