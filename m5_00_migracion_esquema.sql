-- =====================================================================
-- m5_00_migracion_esquema.sql
-- Proyecto integrador RetailPro — Módulo 5
-- Motor: SQL Server (T-SQL)
--
-- El checkpoint de M3 (Ventas_Tech_DB) usó un esquema simplificado que
-- no incluía territorio, segmento de cliente ni canal de venta. Este
-- script amplía ese esquema para alinearlo con el modelo conceptual
-- definido en M1/M2, que sí los requiere (preguntas de negocio por
-- región y por segmento). Ejecutar UNA SOLA VEZ, antes de
-- m5_consultas_joins.sql.
-- =====================================================================

-- 1. Nueva columna: segmento del cliente
ALTER TABLE clientes ADD segmento VARCHAR(50) NULL;
GO

-- 2. Nueva tabla: territorios
CREATE TABLE territorios (
    id_territorio INT PRIMARY KEY,
    region        VARCHAR(50) NOT NULL,
    pais          VARCHAR(50),
    zona          VARCHAR(50)
);
GO

-- 3. Nuevas columnas en ventas: territorio de la venta y canal
ALTER TABLE ventas ADD id_territorio INT NULL;
GO
ALTER TABLE ventas ADD canal VARCHAR(50) NULL;
GO
ALTER TABLE ventas ADD CONSTRAINT fk_ventas_territorio
    FOREIGN KEY (id_territorio) REFERENCES territorios(id_territorio);
GO

-- =====================================================================
-- Carga de territorios
-- =====================================================================
INSERT INTO territorios (id_territorio, region, pais, zona) VALUES
    (1, 'Centro', 'Argentina', 'AMBA / Córdoba / Santa Fe'),
    (2, 'Cuyo',   'Argentina', 'Mendoza / San Juan / San Luis'),
    (3, 'Norte',  'Argentina', 'NOA / NEA'),
    (4, 'Sur',    'Argentina', 'Patagonia');
GO

-- =====================================================================
-- Actualización de segmento por cliente (datos cargados en M3)
-- =====================================================================
UPDATE clientes SET segmento = 'Retail'    WHERE id_cliente = 1;
UPDATE clientes SET segmento = 'Corporate' WHERE id_cliente = 2;
UPDATE clientes SET segmento = 'Retail'    WHERE id_cliente = 3;
UPDATE clientes SET segmento = 'Premium'   WHERE id_cliente = 4;
UPDATE clientes SET segmento = 'Retail'    WHERE id_cliente = 5;
GO

-- =====================================================================
-- Actualización de territorio y canal por venta (datos cargados en M3)
-- =====================================================================
UPDATE ventas SET id_territorio = 1, canal = 'Online'      WHERE id_venta = 1;
UPDATE ventas SET id_territorio = 1, canal = 'Presencial'  WHERE id_venta = 2;
UPDATE ventas SET id_territorio = 1, canal = 'Online'      WHERE id_venta = 3;
UPDATE ventas SET id_territorio = 1, canal = 'Presencial'  WHERE id_venta = 4;
UPDATE ventas SET id_territorio = 2, canal = 'Online'      WHERE id_venta = 5;
UPDATE ventas SET id_territorio = 1, canal = 'Presencial'  WHERE id_venta = 6;
UPDATE ventas SET id_territorio = 3, canal = 'Online'      WHERE id_venta = 7;
UPDATE ventas SET id_territorio = 1, canal = 'Presencial'  WHERE id_venta = 8;
UPDATE ventas SET id_territorio = 2, canal = 'Online'      WHERE id_venta = 9;
UPDATE ventas SET id_territorio = 3, canal = 'Presencial'  WHERE id_venta = 10;
GO

-- =====================================================================
-- Datos adicionales para poder validar las consultas 2 y 3 de M5
-- (un cliente sin ventas y un producto sin ventas)
-- =====================================================================
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro, segmento)
VALUES (6, 'Sofía Medina', 'sofia@mail.com', 'Salta', '2024-04-01', 'Retail');
GO

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES (7, 'Webcam HD', 2, 45.00, 20, 1);
GO

