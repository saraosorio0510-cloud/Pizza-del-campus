# Pizza-del-campus
# Proyecto base de datos - Pizzería

Este proyecto es una base de datos para una pizzería. La idea es tener en un solo lugar los productos, ingredientes, combos, clientes y pedidos.

Con esta base de datos se pueden registrar pizzas, panzarottis, bebidas, postres, adiciones y pedidos para comer en el local o recoger.

## Archivos

- `estructura.sql`: crea la base de datos, las tablas y las relaciones.
- `datos.sql`: agrega datos de prueba.
- `README.md`: explica el proyecto y contiene las consultas.

## Cómo ejecutar el proyecto

1. Abrir MySQL Workbench.
2. Abrir y ejecutar primero el archivo `estructura.sql`.
3. Abrir y ejecutar después el archivo `datos.sql`.
4. Para probar las consultas, copiar una consulta de abajo y ejecutarla en una nueva pestaña.

> Nota: el archivo `estructura.sql` borra la base de datos si ya existe. Se recomienda usarlo solo para pruebas o para la entrega.

## Modelo lógico

Las tablas principales son:

- **producto:** guarda pizzas, panzarottis, bebidas, postres y otros productos.
- **categoria_producto:** indica qué tipo de producto es.
- **ingrediente** y **producto_ingrediente:** guardan los ingredientes de pizzas y panzarottis.
- **adicion:** guarda extras como queso, salsa o borde de queso.
- **combo** y **combo_producto:** indican qué productos contiene cada combo.
- **cliente:** guarda los datos básicos del cliente.
- **pedido** y **pedido_item:** guardan los pedidos y los productos comprados.
- **pedido_item_adicion:** guarda las adiciones que pidió cada cliente.
- **menu:** permite mostrar productos y combos disponibles.

Relaciones importantes:

- Una categoría tiene muchos productos.
- Un producto puede tener varios ingredientes.
- Un combo puede tener varios productos.
- Un cliente puede hacer muchos pedidos.
- Un pedido puede tener varios productos o combos.
- Un producto de un pedido puede tener varias adiciones.


## Consultas

Las consultas cuentan solamente los pedidos que ya fueron entregados (`ENTREGADO`).

### 1. Productos más vendidos

```sql
WITH unidades AS (
 SELECT pi.producto_id, pi.cantidad unidades FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id WHERE pe.estado='ENTREGADO' AND pi.producto_id IS NOT NULL
 UNION ALL
 SELECT cp.producto_id, pi.cantidad*cp.cantidad FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id JOIN combo_producto cp ON cp.combo_id=pi.combo_id WHERE pe.estado='ENTREGADO'
)
SELECT pr.nombre, c.nombre categoria, SUM(u.unidades) unidades_vendidas
FROM unidades u JOIN producto pr ON pr.producto_id=u.producto_id JOIN categoria_producto c ON c.categoria_id=pr.categoria_id
GROUP BY pr.producto_id, pr.nombre, c.nombre ORDER BY unidades_vendidas DESC;
```

### 2. Ingresos de cada combo

```sql
SELECT co.nombre, SUM(pi.cantidad*pi.precio_unitario) ingresos
FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id JOIN combo co ON co.combo_id=pi.combo_id
WHERE pe.estado='ENTREGADO' GROUP BY co.combo_id, co.nombre ORDER BY ingresos DESC;
```

### 3. Pedidos para recoger y para comer en el local

```sql
SELECT tipo_servicio, COUNT(*) cantidad_pedidos
FROM pedido WHERE estado='ENTREGADO' GROUP BY tipo_servicio;
```

### 4. Adiciones más solicitadas

```sql
SELECT a.nombre, SUM(pia.cantidad) veces_solicitada
FROM pedido_item_adicion pia JOIN adicion a ON a.adicion_id=pia.adicion_id
JOIN pedido_item pi ON pi.pedido_item_id=pia.pedido_item_id JOIN pedido pe ON pe.pedido_id=pi.pedido_id
WHERE pe.estado='ENTREGADO' GROUP BY a.adicion_id, a.nombre ORDER BY veces_solicitada DESC;
```

### 5. Total de productos vendidos por categoría

```sql
WITH unidades AS (
 SELECT pi.producto_id,pi.cantidad cantidad FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id WHERE pe.estado='ENTREGADO' AND pi.producto_id IS NOT NULL
 UNION ALL
 SELECT cp.producto_id,pi.cantidad*cp.cantidad FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id JOIN combo_producto cp ON cp.combo_id=pi.combo_id WHERE pe.estado='ENTREGADO'
)
SELECT c.nombre categoria,SUM(u.cantidad) productos_vendidos FROM unidades u JOIN producto pr ON pr.producto_id=u.producto_id JOIN categoria_producto c ON c.categoria_id=pr.categoria_id GROUP BY c.categoria_id,c.nombre;
```

### 6. Promedio de pizzas pedidas por cliente

```sql
WITH pizzas AS (
 SELECT pe.cliente_id,pi.cantidad cantidad FROM pedido pe JOIN pedido_item pi ON pi.pedido_id=pe.pedido_id JOIN producto pr ON pr.producto_id=pi.producto_id JOIN categoria_producto c ON c.categoria_id=pr.categoria_id WHERE pe.estado='ENTREGADO' AND c.nombre='Pizza'
 UNION ALL
 SELECT pe.cliente_id,pi.cantidad*cp.cantidad FROM pedido pe JOIN pedido_item pi ON pi.pedido_id=pe.pedido_id JOIN combo_producto cp ON cp.combo_id=pi.combo_id JOIN producto pr ON pr.producto_id=cp.producto_id JOIN categoria_producto c ON c.categoria_id=pr.categoria_id WHERE pe.estado='ENTREGADO' AND c.nombre='Pizza'
)
SELECT ROUND(SUM(cantidad)/COUNT(DISTINCT cliente_id),2) promedio_pizzas_por_cliente FROM pizzas;
```

### 7. Total de ventas por día de la semana

```sql
SELECT DAYNAME(pe.fecha_hora) dia_semana, SUM(v.total_pedido) total_ventas
FROM pedido pe JOIN vw_total_pedido v ON v.pedido_id=pe.pedido_id
WHERE pe.estado='ENTREGADO' GROUP BY DAYOFWEEK(pe.fecha_hora),DAYNAME(pe.fecha_hora) ORDER BY DAYOFWEEK(pe.fecha_hora);
```

### 8. Panzarottis vendidos con extra queso

```sql
SELECT SUM(pi.cantidad) panzarottis_con_extra_queso
FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id JOIN producto pr ON pr.producto_id=pi.producto_id
JOIN categoria_producto c ON c.categoria_id=pr.categoria_id JOIN pedido_item_adicion pia ON pia.pedido_item_id=pi.pedido_item_id JOIN adicion a ON a.adicion_id=pia.adicion_id
WHERE pe.estado='ENTREGADO' AND c.nombre='Panzarotti' AND a.nombre='Extra queso';
```

### 9. Pedidos que llevan bebida dentro de un combo

```sql
SELECT DISTINCT pe.pedido_id,pe.fecha_hora,cl.nombre cliente
FROM pedido pe JOIN cliente cl ON cl.cliente_id=pe.cliente_id JOIN pedido_item pi ON pi.pedido_id=pe.pedido_id
JOIN combo_producto cp ON cp.combo_id=pi.combo_id JOIN producto pr ON pr.producto_id=cp.producto_id JOIN categoria_producto c ON c.categoria_id=pr.categoria_id
WHERE pe.estado='ENTREGADO' AND c.nombre='Bebida';
```

### 10. Clientes con más de 5 pedidos en el último mes

```sql
SELECT cl.nombre,COUNT(*) pedidos_ultimo_mes FROM cliente cl JOIN pedido pe ON pe.cliente_id=cl.cliente_id
WHERE pe.estado='ENTREGADO' AND pe.fecha_hora>=CURRENT_DATE-INTERVAL 1 MONTH
GROUP BY cl.cliente_id,cl.nombre HAVING COUNT(*)>5;
```

### 11. Ingresos de productos no elaborados

```sql
WITH ventas AS (
 SELECT pi.precio_unitario*pi.cantidad ingreso, pr.categoria_id
 FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id JOIN producto pr ON pr.producto_id=pi.producto_id
 WHERE pe.estado='ENTREGADO'
 UNION ALL
 SELECT pi.precio_unitario*pi.cantidad*(pr.precio_base*cp.cantidad/t.base),pr.categoria_id
 FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id JOIN combo_producto cp ON cp.combo_id=pi.combo_id JOIN producto pr ON pr.producto_id=cp.producto_id
 JOIN (SELECT cp2.combo_id,SUM(p2.precio_base*cp2.cantidad) base FROM combo_producto cp2 JOIN producto p2 ON p2.producto_id=cp2.producto_id GROUP BY cp2.combo_id) t ON t.combo_id=pi.combo_id
 WHERE pe.estado='ENTREGADO'
)
SELECT SUM(v.ingreso) ingresos_no_elaborados FROM ventas v JOIN categoria_producto c ON c.categoria_id=v.categoria_id WHERE c.es_elaborado=FALSE;
```

### 12. Promedio de adiciones por pedido

```sql
SELECT AVG(adiciones) promedio_adiciones_por_pedido FROM (
 SELECT pe.pedido_id,COALESCE(SUM(pia.cantidad),0) adiciones FROM pedido pe LEFT JOIN pedido_item pi ON pi.pedido_id=pe.pedido_id LEFT JOIN pedido_item_adicion pia ON pia.pedido_item_id=pi.pedido_item_id WHERE pe.estado='ENTREGADO' GROUP BY pe.pedido_id
) x;
```

### 13. Total de combos vendidos en el último mes

```sql
SELECT SUM(pi.cantidad) combos_vendidos_ultimo_mes FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id
WHERE pe.estado='ENTREGADO' AND pi.combo_id IS NOT NULL AND pe.fecha_hora>=CURRENT_DATE-INTERVAL 1 MONTH;
```

### 14. Clientes que han pedido para recoger y para comer en el local

```sql
SELECT cl.nombre FROM cliente cl JOIN pedido pe ON pe.cliente_id=cl.cliente_id
WHERE pe.estado='ENTREGADO' GROUP BY cl.cliente_id,cl.nombre
HAVING SUM(pe.tipo_servicio='RECOGER')>0 AND SUM(pe.tipo_servicio='LOCAL')>0;
```

### 15. Total de productos personalizados con adiciones

```sql
SELECT SUM(pi.cantidad) productos_personalizados FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id
WHERE pe.estado='ENTREGADO' AND pi.producto_id IS NOT NULL
AND EXISTS (SELECT 1 FROM pedido_item_adicion pia WHERE pia.pedido_item_id=pi.pedido_item_id);
```

### 16. Pedidos con más de 3 productos diferentes

```sql
WITH productos_pedido AS (
 SELECT pi.pedido_id,pi.producto_id FROM pedido_item pi WHERE pi.producto_id IS NOT NULL
 UNION ALL SELECT pi.pedido_id,cp.producto_id FROM pedido_item pi JOIN combo_producto cp ON cp.combo_id=pi.combo_id
)
SELECT pe.pedido_id,cl.nombre,COUNT(DISTINCT pp.producto_id) productos_diferentes
FROM pedido pe JOIN cliente cl ON cl.cliente_id=pe.cliente_id JOIN productos_pedido pp ON pp.pedido_id=pe.pedido_id
WHERE pe.estado='ENTREGADO' GROUP BY pe.pedido_id,cl.nombre HAVING COUNT(DISTINCT pp.producto_id)>3;
```

### 17. Promedio de ingresos por día

```sql
SELECT AVG(total_dia) promedio_ingreso_diario FROM (
 SELECT DATE(pe.fecha_hora) fecha,SUM(v.total_pedido) total_dia FROM pedido pe JOIN vw_total_pedido v ON v.pedido_id=pe.pedido_id WHERE pe.estado='ENTREGADO' GROUP BY DATE(pe.fecha_hora)
) x;
```

### 18. Clientes que piden pizza con adiciones en más de la mitad de sus pedidos

```sql
SELECT cl.nombre,COUNT(DISTINCT pe.pedido_id) pedidos_totales,
COUNT(DISTINCT CASE WHEN pr.categoria_id=1 AND pia.adicion_id IS NOT NULL THEN pe.pedido_id END) pedidos_pizza_personalizada
FROM cliente cl JOIN pedido pe ON pe.cliente_id=cl.cliente_id LEFT JOIN pedido_item pi ON pi.pedido_id=pe.pedido_id
LEFT JOIN producto pr ON pr.producto_id=pi.producto_id LEFT JOIN pedido_item_adicion pia ON pia.pedido_item_id=pi.pedido_item_id
WHERE pe.estado='ENTREGADO' GROUP BY cl.cliente_id,cl.nombre
HAVING pedidos_pizza_personalizada/NULLIF(pedidos_totales,0)>0.5;
```

### 19. Porcentaje de ventas de productos no elaborados

```sql
WITH ventas AS (
 SELECT pi.precio_unitario*pi.cantidad ingreso,pr.categoria_id FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id JOIN producto pr ON pr.producto_id=pi.producto_id WHERE pe.estado='ENTREGADO'
 UNION ALL
 SELECT pi.precio_unitario*pi.cantidad*(pr.precio_base*cp.cantidad/t.base),pr.categoria_id FROM pedido_item pi JOIN pedido pe ON pe.pedido_id=pi.pedido_id JOIN combo_producto cp ON cp.combo_id=pi.combo_id JOIN producto pr ON pr.producto_id=cp.producto_id JOIN (SELECT cp2.combo_id,SUM(p2.precio_base*cp2.cantidad) base FROM combo_producto cp2 JOIN producto p2 ON p2.producto_id=cp2.producto_id GROUP BY cp2.combo_id) t ON t.combo_id=pi.combo_id WHERE pe.estado='ENTREGADO'
)
SELECT ROUND(100*SUM(CASE WHEN c.es_elaborado=FALSE THEN v.ingreso ELSE 0 END)/NULLIF(SUM(v.ingreso),0),2) porcentaje
FROM ventas v JOIN categoria_producto c ON c.categoria_id=v.categoria_id;
```

### 20. Día con más pedidos para recoger

```sql
SELECT DAYNAME(fecha_hora) dia_semana,COUNT(*) pedidos_recoger FROM pedido
WHERE estado='ENTREGADO' AND tipo_servicio='RECOGER'
GROUP BY DAYOFWEEK(fecha_hora),DAYNAME(fecha_hora) ORDER BY pedidos_recoger DESC LIMIT 1;
```

## Cosas importantes del diseño

- Los precios se guardan en el pedido para que, si un precio cambia después, no cambie el valor de una venta antigua.
- Un producto puede tener ingredientes y un pedido puede llevar adiciones.
- Los combos tienen varios productos y un precio especial.
- La vista `vw_total_pedido` suma los productos y las adiciones de cada pedido.
