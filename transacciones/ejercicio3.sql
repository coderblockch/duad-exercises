-- =========================================================
-- Ejercicio 3: Transacción de Retorno de Productos
-- Devuelve todos los productos de una factura al inventario
-- y la marca como 'Returned'. Si algo falla, RAISE EXCEPTION
-- cancela todo el bloque y nada cambia.
-- =========================================================

DO $$
DECLARE
    -- Factura a devolver (cambiar aquí para probar otros casos)
    v_bill_id INT := 1;

    -- Variables de trabajo
    v_state VARCHAR(20);
    v_line  RECORD;
BEGIN
    -- 1. Verificar que la factura existe
    --    (FOR UPDATE bloquea la factura mientras se procesa la devolución)
    SELECT state INTO v_state
    FROM bills
    WHERE id = v_bill_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Bill % does not exist', v_bill_id;
    END IF;

    -- Protección extra: no devolver dos veces la misma factura
    IF v_state = 'Returned' THEN
        RAISE EXCEPTION 'Bill % was already returned', v_bill_id;
    END IF;

    -- 2. Aumentar el stock con la cantidad registrada en la compra
    FOR v_line IN
        SELECT product_id, quantity
        FROM bill_products
        WHERE bill_id = v_bill_id
    LOOP
        UPDATE products
        SET stock = stock + v_line.quantity
        WHERE id = v_line.product_id;
    END LOOP;

    -- 3. Marcar la factura original como 'Returned'
    UPDATE bills
    SET state = 'Returned'
    WHERE id = v_bill_id;

    RAISE NOTICE 'Bill % returned successfully', v_bill_id;
END $$;
