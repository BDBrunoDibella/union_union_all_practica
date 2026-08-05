# Consolidador de Inventarios — RetailChain

Este proyecto contiene la resolución técnica para la unificación y auditoría de datos de inventario entre sucursales utilizando los operadores `UNION` y `UNION ALL` en SQL Server.

---

## Cuestionario de Análisis Técnico

### 1. ¿Cuántas filas devuelve cada consulta y por qué son distintas?

* **Consulta 1 (`UNION`):** devuelve **11 filas**.
* **Consulta 2 (`UNION ALL`):** devuelve **14 filas**.

**Explicación con datos del ejercicio:**

Ambas tablas poseen 7 registros cada una, dando un total acumulado de 14 filas.

Al ejecutar la Consulta 1 (`UNION`) seleccionando `id_producto`, `nombre_producto` y `categoria`, SQL Server evalúa la coincidencia total de los campos proyectados. Los siguientes 3 productos existen en ambas sucursales con exactamente los mismos atributos:

* `103 | Monitor 4K 27" | Computación`
* `104 | Teclado Mecánico | Accesorios`
* `106 | SSD Externo 1TB | Almacenamiento`

El operador `UNION` elimina estas 3 filas redundantes, resultando en 11 registros únicos.

**Nota sobre la exclusión de `stock`:** la Consulta 1 proyecta deliberadamente sólo tres columnas. Si se incluyera `stock`, esos mismos 3 productos dejarían de constituir filas idénticas, porque cada sucursal declara una existencia distinta (103: 5 y 3; 104: 20 y 18; 106: 10 y 7). El `UNION` no eliminaría ninguna fila y ambas consultas devolverían 14 registros. La decisión responde a la pregunta de negocio: el catálogo comercial informa **qué** se comercializa, no **cuánto** hay en depósito. El operador deduplica filas completas, no productos.

**Nota sobre la Webcam:** la unidad de la Sucursal Norte tiene ID `107` y la de la Sucursal Sur, ID `111`. Como sus identificadores difieren, la fila no se considera un duplicado idéntico y ambas se conservan, aun compartiendo nombre y categoría.

---

### 2. ¿Por qué `UNION ALL` es más eficiente que `UNION`?

`UNION ALL` es técnicamente más eficiente porque realiza una simple concatenación de los conjuntos de resultados. Su complejidad algorítmica es de orden lineal respecto al número de filas.

Por el contrario, `UNION` exige garantizar la unicidad del resultado. Para ello, el motor de SQL Server debe realizar internamente una operación adicional de eliminación de duplicados mediante un algoritmo de ordenamiento (`Sort / Distinct`) o una tabla hash (`Hash Match`). Este proceso consume memoria adicional (RAM/TempDB) y tiempo de procesamiento en CPU.

---

### 3. Casos de uso de negocio para cada operador

#### Casos para `UNION`:

1. **Consolidación de listas de contactos para marketing:** combinar listas de clientes provenientes de distintas plataformas (por ejemplo, CRM comercial y base de e-commerce) para enviar un boletín informativo, evitando enviar correos duplicados al mismo destinatario.
2. **Catálogo unificado de proveedores:** unificar listas de marcas o categorías suministradas por múltiples distribuidores para desplegar un directorio consolidado en una plataforma web.

#### Casos para `UNION ALL`:

1. **Auditoría de transacciones financieras:** consolidar libros diarios de ventas o cobros de múltiples sucursales para calcular ingresos totales o contar la cantidad de operaciones físicas procesadas.
2. **Consolidación de bitácoras (logs):** unificar archivos de eventos o errores generados en distintos servidores para su posterior análisis de volumen en herramientas de monitoreo.

---

### 4. Incompatibilidad de columnas y errores de SQL

Si las consultas combinadas difieren en sus estructuras, SQL Server interrumpe la ejecución según el tipo de discrepancia:

* **Distinta cantidad de columnas:** se genera un error de validación (error 205), detectado antes de la ejecución:
  `All queries combined using a UNION, INTERSECT or EXCEPT operator must have an equal number of expressions in their target lists.`

* **Incompatibilidad en tipos de datos:** si el número de columnas coincide pero sus tipos no permiten conversión implícita (por ejemplo, combinar un `INT` con un `VARCHAR` no numérico), SQL Server arroja un error de conversión:
  `Conversion failed when converting the varchar value '...' to data type int.`

---

## Nota sobre el motor de base de datos

Las consultas fueron escritas y probadas en **SQL Server**. El `ORDER BY` se ubica al final de la sentencia completa, nunca dentro de cada `SELECT` individual, ya que ordena el conjunto resultante de la unión y no cada operando por separado.
