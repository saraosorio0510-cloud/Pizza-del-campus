USE pizzeria_sabor_italiano;

-- Categorías: elaborado = pizza/panzarotti; no elaborado = bebida/postre/otros.
INSERT INTO categoria_producto (nombre, es_elaborado, descripcion) VALUES
('Pizza', TRUE, 'Pizzas preparadas al momento'),
('Panzarotti', TRUE, 'Masa rellena y frita'),
('Bebida', FALSE, 'Bebidas embotelladas o en lata'),
('Postre', FALSE, 'Postres listos para servir'),
('Complemento', FALSE, 'Productos no elaborados adicionales');

INSERT INTO ingrediente (nombre, unidad_medida) VALUES
('Masa de pizza', 'g'), ('Salsa de tomate', 'g'), ('Queso mozzarella', 'g'),
('Pepperoni', 'g'), ('Jamón', 'g'), ('Piña', 'g'), ('Pollo', 'g'),
('Carne molida', 'g'), ('Champiñones', 'g');

INSERT INTO producto (categoria_id, nombre, descripcion, precio_base) VALUES
(1, 'Pizza hawaiana mediana', 'Pizza con jamón, piña y mozzarella', 28000),
(1, 'Pizza pepperoni mediana', 'Pizza con pepperoni y mozzarella', 30000),
(1, 'Pizza pollo y champiñones mediana', 'Pizza con pollo y champiñones', 32000),
(2, 'Panzarotti de carne', 'Panzarotti relleno de carne y queso', 12000),
(2, 'Panzarotti de pollo', 'Panzarotti relleno de pollo y queso', 12000),
(3, 'Gaseosa 350 ml', 'Bebida gaseosa en lata', 4500),
(3, 'Agua 600 ml', 'Agua embotellada', 3000),
(4, 'Tiramisú individual', 'Postre refrigerado', 8500),
(4, 'Brownie con helado', 'Postre listo para servir', 9000),
(5, 'Papas fritas', 'Porción individual', 6000);

INSERT INTO producto_ingrediente (producto_id, ingrediente_id, cantidad) VALUES
(1,1,280),(1,2,90),(1,3,180),(1,5,80),(1,6,70),
(2,1,280),(2,2,90),(2,3,180),(2,4,110),
(3,1,280),(3,2,90),(3,3,180),(3,7,100),(3,9,70),
(4,1,180),(4,3,100),(4,8,100),
(5,1,180),(5,3,100),(5,7,100);

INSERT INTO adicion (nombre, descripcion, precio) VALUES
('Extra queso', 'Porción adicional de mozzarella', 3500),
('Salsa de ajo', 'Salsa adicional', 1500),
('Borde de queso', 'Borde relleno de queso', 5000),
('Extra pepperoni', 'Porción adicional de pepperoni', 4000);

INSERT INTO combo (nombre, descripcion, precio_especial) VALUES
('Combo personal', 'Pizza hawaiana, gaseosa y papas', 35000),
('Combo pareja', 'Dos panzarottis y dos gaseosas', 31000),
('Combo familiar', 'Dos pizzas medianas y gaseosa', 59000);

INSERT INTO combo_producto (combo_id, producto_id, cantidad) VALUES
(1,1,1),(1,6,1),(1,10,1),
(2,4,1),(2,5,1),(2,6,2),
(3,1,1),(3,2,1),(3,6,1);

INSERT INTO menu (nombre, fecha_inicio, activo) VALUES
('Menú principal vigente', CURRENT_DATE - INTERVAL 90 DAY, TRUE);
INSERT INTO menu_producto (menu_id, producto_id)
SELECT 1, producto_id FROM producto WHERE disponible = TRUE;
INSERT INTO menu_combo (menu_id, combo_id)
SELECT 1, combo_id FROM combo WHERE disponible = TRUE;

INSERT INTO cliente (nombre, telefono, correo) VALUES
('Laura Gómez', '3001112233', 'laura@example.com'),
('Carlos Pérez', '3002223344', 'carlos@example.com'),
('Ana Martínez', '3003334455', 'ana@example.com'),
('Diego Torres', '3004445566', 'diego@example.com'),
('Sofía Ramírez', '3005556677', 'sofia@example.com');

-- Fechas relativas: conservan los escenarios de "último mes" al ejecutar el proyecto.
INSERT INTO pedido (cliente_id, fecha_hora, tipo_servicio, estado, observaciones) VALUES
(1, CURRENT_DATE - INTERVAL 28 DAY + INTERVAL 13 HOUR, 'RECOGER', 'ENTREGADO', NULL),
(1, CURRENT_DATE - INTERVAL 24 DAY + INTERVAL 19 HOUR, 'LOCAL', 'ENTREGADO', 'Mesa 4'),
(1, CURRENT_DATE - INTERVAL 20 DAY + INTERVAL 12 HOUR, 'RECOGER', 'ENTREGADO', NULL),
(1, CURRENT_DATE - INTERVAL 16 DAY + INTERVAL 18 HOUR, 'LOCAL', 'ENTREGADO', 'Mesa 2'),
(1, CURRENT_DATE - INTERVAL 12 DAY + INTERVAL 20 HOUR, 'RECOGER', 'ENTREGADO', NULL),
(1, CURRENT_DATE - INTERVAL 8 DAY + INTERVAL 13 HOUR, 'LOCAL', 'ENTREGADO', 'Mesa 6'),
(2, CURRENT_DATE - INTERVAL 7 DAY + INTERVAL 19 HOUR, 'RECOGER', 'ENTREGADO', NULL),
(3, CURRENT_DATE - INTERVAL 6 DAY + INTERVAL 18 HOUR, 'LOCAL', 'ENTREGADO', 'Mesa 1'),
(4, CURRENT_DATE - INTERVAL 4 DAY + INTERVAL 12 HOUR, 'RECOGER', 'ENTREGADO', NULL),
(5, CURRENT_DATE - INTERVAL 2 DAY + INTERVAL 20 HOUR, 'LOCAL', 'ENTREGADO', 'Sin cebolla'),
(2, CURRENT_DATE - INTERVAL 1 DAY + INTERVAL 13 HOUR, 'RECOGER', 'ENTREGADO', NULL),
(3, CURRENT_DATE + INTERVAL 1 HOUR, 'RECOGER', 'PENDIENTE', 'Llamar al llegar');

-- producto_id o combo_id; los precios se guardan como historial de la venta.
INSERT INTO pedido_item (pedido_id, producto_id, combo_id, cantidad, precio_unitario, notas_personalizacion) VALUES
(1,NULL,1,1,35000,NULL),(1,8,NULL,1,8500,NULL),
(2,2,NULL,1,30000,'Sin orégano'),(2,6,NULL,1,4500,NULL),
(3,4,NULL,2,12000,NULL),(3,6,NULL,2,4500,NULL),
(4,NULL,2,1,31000,NULL),(4,9,NULL,1,9000,NULL),
(5,3,NULL,1,32000,NULL),(5,7,NULL,1,3000,NULL),
(6,NULL,3,1,59000,NULL),
(7,1,NULL,1,28000,NULL),(7,10,NULL,1,6000,NULL),
(8,5,NULL,2,12000,NULL),(8,6,NULL,1,4500,NULL),
(9,NULL,1,1,35000,NULL),(9,4,NULL,1,12000,NULL),
(10,2,NULL,1,30000,NULL),(10,8,NULL,1,8500,NULL),(10,6,NULL,1,4500,NULL),(10,10,NULL,1,6000,NULL),
(11,NULL,2,1,31000,NULL),(11,1,NULL,1,28000,NULL),
(12,3,NULL,1,32000,'Cortar en ocho porciones');

INSERT INTO pedido_item_adicion (pedido_item_id, adicion_id, cantidad, precio_unitario) VALUES
(3,1,1,3500),(5,1,1,3500),(9,1,1,3500),(9,2,1,1500),
(12,1,1,3500),(18,4,1,4000),(23,1,1,3500),(23,3,1,5000),(24,1,1,3500);
