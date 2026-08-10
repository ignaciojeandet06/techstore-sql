-- =====================================================================
-- m4_consultas_negocio.sql
-- Proyecto integrador RetailPro — Módulo 4: Pre-entrega evaluable
-- Extrayendo métricas clave con SQL (COUNT, SUM, AVG, GROUP BY, HAVING, CASE)
--
-- Base de datos: Ventas_Tech_DB (creada en M3)
-- Motor: SQL Server (T-SQL)
-- Se trabaja únicamente sobre la tabla ventas:
--   ventas(id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
-- =====================================================================


-- =====================================================================
-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes.
-- =====================================================================

SELECT
    MONTH(fecha_venta)                           AS mes,
    COUNT(*)                                     AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)              AS total_facturado,
    ROUND(AVG(cantidad * precio_unitario), 2)    AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- =====================================================================
-- Consulta 2 — Ranking de productos
-- Top 5 de id_producto por total facturado, con unidades vendidas.
-- =====================================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad)                      AS unidades_vendidas,
    SUM(cantidad * precio_unitario)    AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;


-- =====================================================================
-- Consulta 3 — Clientes recurrentes
-- Clientes con más de un pedido, con cantidad de pedidos y total gastado.
-- =====================================================================

SELECT
    id_cliente,
    COUNT(*)                           AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)    AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- =====================================================================
-- Consulta 4 — Meses por encima/por debajo del promedio
-- Total facturado por mes, etiquetado contra el promedio mensual general.
-- =====================================================================

SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_mes) FROM (
            SELECT SUM(cantidad * precio_unitario) AS total_mes
            FROM ventas
            GROUP BY MONTH(fecha_venta)
        ) AS totales_por_mes)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_vs_promedio
FROM (
    SELECT
        MONTH(fecha_venta)                   AS mes,
        SUM(cantidad * precio_unitario)      AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
) AS resumen_mensual
ORDER BY mes;


-- =====================================================================
-- Hallazgos (resultados reales obtenidos al ejecutar las 4 consultas
-- de arriba sobre Ventas_Tech_DB, cargada en M3)
-- =====================================================================
-- 1. Las 10 transacciones cargadas en M3 caen todas en marzo (mes 3), con
--    un total facturado de $ 6.444,00 y un ticket promedio de $ 644,40
--    (Consulta 1). Como es el único mes con datos, la Consulta 4 lo
--    marca "Por debajo" del promedio general por definición (el promedio
--    de un solo mes es igual a sí mismo): este resultado va a volverse
--    informativo recién cuando se carguen ventas de más meses.
-- 2. El producto 1 (Laptop Pro 15) lidera el ranking de facturación
--    (Consulta 2) con solo 3 unidades vendidas pero $ 3.600,00 generados:
--    concentra cerca del 56% del total facturado del período, muy por
--    delante del producto 3 ($ 1.350,00) pese a vender la misma cantidad
--    de unidades — evidencia de que el precio unitario, no el volumen,
--    explica el ranking.
-- 3. Los 5 clientes registrados son recurrentes (Consulta 3): todos
--    realizaron exactamente 2 pedidos. El cliente 1 es el que más gastó
--    en total ($ 2.640,00), seguido del cliente 5 ($ 2.100,00); ambos
--    superan ampliamente al resto, que gastó entre $ 510,00 y $ 674,00.
-- =====================================================================
