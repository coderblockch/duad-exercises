-- =========================================================
-- Ejercicio 1: Creación de la base de datos
-- Entidades: users, products, bills (+ tabla cruz bill_products)
-- =========================================================

DROP TABLE IF EXISTS bill_products;
DROP TABLE IF EXISTS bills;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

-- Usuarios que realizan compras
CREATE TABLE users (
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Productos con su inventario
CREATE TABLE products (
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100)   NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT            NOT NULL CHECK (stock >= 0)
);

-- Facturas: cada una pertenece a un usuario y tiene un estado
CREATE TABLE bills (
    id            SERIAL PRIMARY KEY,
    user_id       INT            NOT NULL REFERENCES users(id),
    purchase_date TIMESTAMP      NOT NULL DEFAULT NOW(),
    total_amount  DECIMAL(10, 2) NOT NULL DEFAULT 0,
    state         VARCHAR(20)    NOT NULL DEFAULT 'Completed'
);

-- Tabla cruz (N:N): cada línea de una factura
CREATE TABLE bill_products (
    id         SERIAL PRIMARY KEY,
    bill_id    INT            NOT NULL REFERENCES bills(id),
    product_id INT            NOT NULL REFERENCES products(id),
    quantity   INT            NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL
);

-- Datos de prueba
INSERT INTO users (name, email) VALUES
    ('David Jimenez', 'david@email.com'),
    ('Jane Doe', 'jane@email.com');

INSERT INTO products (name, price, stock) VALUES
    ('Milk',  2.50, 20),
    ('Bread', 3.00, 15),
    ('Eggs',  4.75, 10);
