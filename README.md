# Auditoría de Inventario y Ventas — MiniStore

Este proyecto contiene las soluciones en SQL Server para analizar la calidad de datos en el inventario y las ventas de MiniStore mediante el uso de **Outer JOINs**.

---

## Estructura del repositorio

```
outer-joins-ministore/
├── schema.sql
├── soluciones.sql
└── README.md
```

Cada consulta de `soluciones.sql` se presenta en dos versiones: la vista completa (`a`), que conserva todas las filas y permite leer los NULL en su contexto, y la versión filtrada (`b`), que aísla exactamente los registros que responden la pregunta de negocio.

---

## Respuestas al cuestionario de análisis

### 1. ¿Por qué se usó LEFT JOIN para la Consulta 1 y no INNER JOIN? ¿Qué se perdería con INNER JOIN?

Se utilizó `LEFT JOIN` para preservar la totalidad de los registros de la tabla `productos` (tabla izquierda en la sentencia), independientemente de si existe coincidencia en la tabla `ventas`.

Si se hubiera utilizado un `INNER JOIN`, los productos que nunca generaron una transacción (como el *Hub USB-C 7p* y el *Parlante Bluetooth*) habrían sido descartados del resultado, impidiendo responder la pregunta de negocio planteada.

### 2. ¿Por qué se usó RIGHT JOIN para la Consulta 2? ¿Qué tabla está a la izquierda y cuál a la derecha?

Se empleó `RIGHT JOIN` porque el objetivo del análisis era auditar la integridad de la tabla de transacciones (`ventas`).

* **Tabla a la izquierda:** `productos`
* **Tabla a la derecha:** `ventas`

Al estar `ventas` a la derecha, la consulta asegura que no se omita ninguna transacción registrada, permitiendo detectar aquellas cuya referencia de producto no coincida con ningún elemento del catálogo.

### 3. ¿Qué representan los valores NULL en cada resultado?

* **En la Consulta 1 (`venta_id IS NULL`):** representa productos existentes en la base de datos que no registran actividad comercial en el historial de transacciones. Por ejemplo, para los productos 108 (*Hub USB-C 7p*) y 109 (*Parlante Bluetooth*), la columna `venta_id` devuelve `NULL` porque no hay filas en `ventas` asociadas a esos identificadores.

* **En la Consulta 2 (`producto_id IS NULL` de la tabla `productos`):** representa una falla de integridad referencial. Por ejemplo, en la venta con `venta_id = 10`, el campo `producto_id` tiene el valor `999`. Al no existir ese código en la tabla `productos`, todas las columnas provenientes del catálogo retornan `NULL`.

En ambos casos el filtro se aplica deliberadamente sobre la clave primaria de la tabla del lado no preservado (`ventas.venta_id` y `productos.producto_id`). Al tratarse de columnas que nunca admiten `NULL` en la tabla de origen, un `NULL` en el resultado solo puede haberse generado por la ausencia de coincidencia en el JOIN. Filtrar sobre una columna que sí acepta nulos —por ejemplo `ventas.producto_id`— produciría falsos positivos.

### 4. ¿Cuándo se usaría FULL OUTER JOIN en un caso real de negocio?

El `FULL OUTER JOIN` se utiliza en procesos globales de conciliación o auditoría de datos entre dos sistemas dispares (por ejemplo, al cruzar el inventario del sistema ERP con el sistema de cobros o pasarela de pagos). Permite obtener en una única salida tanto los elementos del catálogo que no han tenido actividad como las transacciones huérfanas que requieren corrección operativa.

---

## Nota sobre el motor de base de datos

Las consultas fueron escritas y probadas en **SQL Server**, que soporta `FULL OUTER JOIN` de forma nativa. MySQL no lo implementa, por lo que la Consulta 3 debería simularse combinando ambas uniones externas:

```sql
SELECT ... FROM productos p LEFT  JOIN ventas v ON p.producto_id = v.producto_id
UNION
SELECT ... FROM productos p RIGHT JOIN ventas v ON p.producto_id = v.producto_id;
```

Se usa `UNION` y no `UNION ALL` porque las filas coincidentes aparecen en ambas mitades y deben deduplicarse.
