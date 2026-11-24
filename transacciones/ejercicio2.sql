-- =========================================================
-- Ejercicio 2: Transacción de Compra
-- Compra de múltiples productos dentro de un bloque anónimo.
-- Si cualquier validación falla, RAISE EXCEPTION cancela
-- todo el bloque y la base de datos queda como estaba.
-- =========================================================

DO $$
DECLARE
    -- Datos de la compra (cambiar aquí para probar otros casos)
    v_user_id     INT   := 1;
    v_product_ids INT[] := ARRAY[1, 2];   -- Milk, Bread
    v_quantities  INT[] := ARRAY[3, 2];   -- 3 Milk, 2 Bread

    -- Variables de trabajo
    v_bill_id INT;
    v_stock   INT;
    v_price   DECIMAL(10, 2);
    v_total   DECIMAL(10, 2) := 0;
    i         INT;
BEGIN
    -- 1. Confirmar que el usuario existe
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = v_user_id) THEN
        RAISE EXCEPTION 'User % does not exist', v_user_id;
    END IF;

    -- 2. Comprobar que hay stock suficiente de CADA producto
    --    (FOR UPDATE bloquea la fila para que nadie más la cambie mientras compramos)
    FOR i IN 1 .. array_length(v_product_ids, 1) LOOP
        SELECT stock INTO v_stock
        FROM products
        WHERE id = v_product_ids[i]
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Product % does not exist', v_product_ids[i];
        END IF;

        IF v_stock < v_quantities[i] THEN
            RAISE EXCEPTION 'Not enough stock for product %: available %, requested %',
                v_product_ids[i], v_stock, v_quantities[i];
        END IF;
    END LOOP;

    -- 3. Insertar la factura con el usuario relacionado
    INSERT INTO bills (user_id)
    VALUES (v_user_id)
    RETURNING id INTO v_bill_id;

    -- 4. Registrar cada producto y reducir su stock
    FOR i IN 1 .. array_length(v_product_ids, 1) LOOP
        SELECT price INTO v_price
        FROM products
        WHERE id = v_product_ids[i];

        INSERT INTO bill_products (bill_id, product_id, quantity, unit_price)
        VALUES (v_bill_id, v_product_ids[i], v_quantities[i], v_price);

        UPDATE products
        SET stock = stock - v_quantities[i]
        WHERE id = v_product_ids[i];

        v_total := v_total + (v_price * v_quantities[i]);
    END LOOP;

    -- 5. Guardar el total de la factura
    UPDATE bills
    SET total_amount = v_total
    WHERE id = v_bill_id;

    RAISE NOTICE 'Purchase completed. Bill id: %, total: %', v_bill_id, v_total;
END $$;
