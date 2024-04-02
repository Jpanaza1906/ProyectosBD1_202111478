create PROCEDURE realizarDebito(
    p_id_debito IN NUMBER,
    p_fecha_str IN VARCHAR2,
    p_monto IN NUMBER,    
    p_detalle IN VARCHAR2,
    p_id_cliente IN NUMBER
) AS
    v_fecha DATE;
    v_id_cliente_exist NUMBER;
    v_detalle VARCHAR2(40);
BEGIN
    IF p_fecha_str IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: La fecha es un parametro obligatorio.');
        RETURN;
    end if;
    
    BEGIN
        --Convertir la cadena de fecha a fecha
        v_fecha := TO_DATE(p_fecha_str, 'DD/MM/YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha no tiene el formato correcto.');
            RETURN;
    end;

    --Verificar el campo opcional de detalle
    
    IF p_detalle = '' THEN
        v_detalle := NULL;
    ELSE
        v_detalle := p_detalle;
    end if;

    -- Verificar que exista el id
    SELECT COUNT(*) INTO v_id_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La id de cliente no existe.');
        RETURN;
    end if;

    -- Verificar que el monto sea mayor a 0
     IF p_monto <= 0 THEN
         RAISE_APPLICATION_ERROR(-20001, 'El monto debe ser mayor a 0.');
         RETURN;
     end if;

        -- Insertar el debito
    INSERT INTO DEBITO (ID_DEBITO, FECHA, MONTO, DETALLE, ID_CLIENTE)
    VALUES (p_id_debito, v_fecha, p_monto, v_detalle, p_id_cliente);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Debito asignado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar el debito: ' || SQLERRM);
        ROLLBACK;
end;
/

