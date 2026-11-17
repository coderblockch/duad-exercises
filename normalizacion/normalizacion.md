# Ejercicios de Normalización

**Autor:** David Jiménez
**Módulo:** Bases de Datos — Normalización

---

## ¿Qué es normalizar?

Normalizar es organizar los datos en tablas para **eliminar la redundancia** y **evitar anomalías** (datos repetidos o inconsistentes). Se hace por niveles:

- **1NF:** valores atómicos (una sola cosa por celda), sin grupos repetidos, y una **clave primaria (PK)** que identifique cada fila.
- **2NF:** estar en 1NF + cada columna no-clave depende de la **clave completa**, no de una parte (importa cuando la PK es compuesta → elimina **dependencias parciales**).
- **3NF:** estar en 2NF + ninguna columna no-clave depende de **otra columna no-clave** (elimina **dependencias transitivas**).

---

# Ejercicio 1: Orders

## Tabla original (sin normalizar)

| Order ID | Customer Name | Customer Phone | Address | Item ID | Item Name | Price | Quantity | Special Request | Delivery Time |
|---|---|---|---|---|---|---|---|---|---|
| 001 | Alice | 123-456-7890 | 123 Main St | 101 | Cheeseburger | $8 | 2 | No onions | 6:00 PM |
| 001 | Alice | 123-456-7890 | 123 Main St | 102 | Fries | $3 | 1 | Extra ketchup | 6:00 PM |
| 002 | Bob | 987-654-3210 | 456 Elm St | 103 | Pizza | $12 | 1 | Extra cheese | 7:30 PM |
| 002 | Bob | 987-654-3210 | 4th Avenue | 102 | Fries | $3 | 2 | None | 7:30 PM |
| 003 | Claire | 555-123-4567 | 789 Oak St | 105 | Salad | $6 | 1 | No croutons | 12:00 PM |
| 004 | Claire | 555-123-4567 | 464 Georgia St | 106 | Water | $1 | 1 | None | 5:00 PM |

**Problema:** los datos del cliente y de la orden se repiten en cada fila de ítem, y un producto (Fries) se repite en varias órdenes. Eso es redundancia.

## Paso 1 — Primera Forma Normal (1NF)

Los valores ya son **atómicos** (una sola cosa por celda). Lo que falta es definir la **clave primaria**. Como una orden tiene **varios ítems**, una sola columna no identifica cada fila: la clave es **compuesta**.

- **PK: (`order_id`, `item_id`)**

**Justificación:** la combinación de orden + ítem identifica de forma única cada línea de la tabla.

## Paso 2 — Segunda Forma Normal (2NF)

Con la clave compuesta `(order_id, item_id)`, revisamos de qué depende cada columna para eliminar las **dependencias parciales**:

| Columna | Depende de | Destino |
|---|---|---|
| customer_name, customer_phone, address, delivery_time | solo `order_id` | tabla `orders` |
| item_name, price | solo `item_id` | tabla `items` |
| quantity, special_request | de **ambos** (la clave completa) | tabla `order_items` |

**Tablas en 2NF:**

**`orders`**

| Columna | Tipo | Clave |
|---|---|---|
| order_id | INT | PK |
| customer_name | VARCHAR(100) | |
| customer_phone | VARCHAR(20) | |
| address | VARCHAR(150) | |
| delivery_time | TIME | |

**`items`**

| Columna | Tipo | Clave |
|---|---|---|
| item_id | INT | PK |
| item_name | VARCHAR(100) | |
| price | DECIMAL(10,2) | |

**`order_items`**

| Columna | Tipo | Clave |
|---|---|---|
| order_id | INT | PK / FK → orders |
| item_id | INT | PK / FK → items |
| quantity | INT | |
| special_request | VARCHAR(100) | |

**Justificación:** `item_name` y `price` dependían solo del ítem, y los datos del cliente solo de la orden. Al separarlos, cada dato vive en un solo lugar.

## Paso 3 — Tercera Forma Normal (3NF)

Buscamos **dependencias transitivas** (una columna no-clave que depende de otra columna no-clave).

En `orders`, el `customer_name` y el `customer_phone` describen al **cliente**, no a la orden. El cliente es una entidad aparte → lo extraemos a su propia tabla.

> **Nota sobre `address`:** en los datos, Bob y Claire tienen **direcciones distintas en órdenes distintas** (Bob: "456 Elm St" y "4th Avenue"). Por eso la dirección **no** es un dato fijo del cliente, sino la **dirección de entrega de cada orden** → se queda en `orders`. El teléfono, en cambio, sí es constante por cliente.

## ✅ Solución final — Orders (3NF)

**`customers`**

| Columna | Tipo | Clave |
|---|---|---|
| customer_id | INT | PK |
| name | VARCHAR(100) | |
| phone | VARCHAR(20) | |

**`orders`**

| Columna | Tipo | Clave |
|---|---|---|
| order_id | INT | PK |
| customer_id | INT | FK → customers |
| delivery_address | VARCHAR(150) | |
| delivery_time | TIME | |

**`items`**

| Columna | Tipo | Clave |
|---|---|---|
| item_id | INT | PK |
| item_name | VARCHAR(100) | |
| price | DECIMAL(10,2) | |

**`order_items`**

| Columna | Tipo | Clave |
|---|---|---|
| order_id | INT | PK / FK → orders |
| item_id | INT | PK / FK → items |
| quantity | INT | |
| special_request | VARCHAR(100) | |

---

# Ejercicio 2: Cars

## Tabla original (sin normalizar)

| VIN | Make | Model | Year | Color | Owner ID | Owner Name | Owner Phone | Insurance Company | Insurance Policy |
|---|---|---|---|---|---|---|---|---|---|
| 1HGCM82633A | Honda | Accord | 2003 | Silver | 101 | Alice | 123-456-7890 | ABC Insurance | Fire & Theft |
| 1HGCM82633A | Honda | Accord | 2003 | Silver | 102 | Bob | 987-654-3210 | XYZ Insurance | Full Cover |
| 5J6RM4H79EL | Honda | CR-V | 2014 | Blue | 103 | Claire | 555-123-4567 | DEF Insurance | Collision |
| 1G1RA6EH1FU | Chevrolet | Volt | 2015 | Red | 104 | Dave | 111-222-3333 | GHI Insurance | Basic Legal |

**Observación clave:** el mismo auto (VIN `1HGCM82633A`) aparece con **dos dueños** (Alice y Bob). Y un dueño podría tener varios autos. Es una relación **muchos a muchos (N:N)**.

## Paso 1 — Primera Forma Normal (1NF)

Los valores son atómicos. Definimos la **clave primaria compuesta**:

- **PK: (`vin`, `owner_id`)**

**Justificación:** como un auto puede tener muchos dueños **y** un dueño muchos autos (N:N), se necesitan **las dos columnas juntas** para identificar cada fila. Un N:N está hecho de dos relaciones 1:N unidas por una tabla intermedia.

## Paso 2 — Segunda Forma Normal (2NF)

Con la clave `(vin, owner_id)`, eliminamos las **dependencias parciales**:

| Columna | Depende de | Destino |
|---|---|---|
| make, model, year, color | solo `vin` (el auto) | tabla `cars` |
| owner_name, owner_phone, insurance_company, insurance_policy | solo `owner_id` (el dueño) | tabla `owners` |
| (ninguna columna extra) | de ambos | tabla `car_owners` |

**Tablas en 2NF:**

**`cars`** → vin (PK), make, model, year, color
**`owners`** → owner_id (PK), owner_name, owner_phone, insurance_company, insurance_policy
**`car_owners`** → (vin, owner_id) PK compuesta, ambas FK

**Justificación:** los datos del auto dependían solo del VIN, y los del dueño solo del Owner ID. La tabla intermedia `car_owners` sostiene la relación N:N.

## Paso 3 — Tercera Forma Normal (3NF)

En las tablas del paso anterior quedaban varias **dependencias transitivas escondidas**. Las corregimos una por una:

**a) El modelo del vehículo no pertenece al `vin`.** Los campos `make`, `model` y `year` no describen al auto específico (identificado por el `vin`), sino al **modelo** (ej: "Honda Accord 2003"). Si hubiera 500 autos del mismo modelo, esos valores se repetirían en 500 filas. → Se extraen a una tabla `car_models`. El `color` **sí** pertenece al auto específico, así que se queda en `cars`.

**b) El seguro pertenece al auto, no al dueño.** Una póliza asegura un **vehículo**, no a una persona (si el auto se vende, la póliza va con el auto). → El vínculo del seguro se mueve a `cars`, y `owners` queda solo con los datos de la persona.

**c) La compañía y la póliza son entidades distintas.** El nombre de la aseguradora se repetiría por cada póliza que ofrezca (si "ABC Insurance" tuviera 20 pólizas, el string se repetiría 20 veces). → Se separan en `insurance_companies` y `policies`, donde cada póliza pertenece a una compañía mediante una FK.

## ✅ Solución final — Cars (3NF)

**`car_models`**

| Columna | Tipo | Clave |
|---|---|---|
| model_id | INT | PK |
| make | VARCHAR(50) | |
| model | VARCHAR(50) | |
| year | INT | |

**`cars`**

| Columna | Tipo | Clave |
|---|---|---|
| vin | VARCHAR(20) | PK |
| color | VARCHAR(30) | |
| model_id | INT | FK → car_models |
| policy_id | INT | FK → policies |

**`insurance_companies`**

| Columna | Tipo | Clave |
|---|---|---|
| company_id | INT | PK |
| company_name | VARCHAR(100) | |

**`policies`**

| Columna | Tipo | Clave |
|---|---|---|
| policy_id | INT | PK |
| policy_name | VARCHAR(50) | |
| company_id | INT | FK → insurance_companies |

**`owners`**

| Columna | Tipo | Clave |
|---|---|---|
| owner_id | INT | PK |
| owner_name | VARCHAR(100) | |
| owner_phone | VARCHAR(20) | |

**`car_owners`**

| Columna | Tipo | Clave |
|---|---|---|
| vin | VARCHAR(20) | PK / FK → cars |
| owner_id | INT | PK / FK → owners |

---

## Conclusión

En ambos ejercicios pasamos de una tabla con datos repetidos a un conjunto de tablas donde **cada dato vive en un solo lugar**, conectadas por llaves primarias y foráneas. Orders quedó en **4 tablas** y Cars en **6 tablas**, todas en 3NF, sin redundancia ni anomalías.
