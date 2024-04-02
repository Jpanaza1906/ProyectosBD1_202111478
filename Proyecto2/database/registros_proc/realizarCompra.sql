create PROCEDURE realizarCompra(
    p_id_compra IN NUMBER,
    p_fecha_str IN VARCHAR2,    
    p_importe IN NUMBER,    
    p_detalle IN VARCHAR2,
    p_id_pro_ser IN NUMBER,
    p_id_cliente IN NUMBER
) AS
    v_fecha DATE;
    v_id_cliente_exist NUMBER;
    v_id_pro_ser_exist NUMBER;
    v_tipo_pro_ser NUMBER;
    v_importe NUMBER;
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
    
    --Verificar el dato opcional de importe
    IF p_importe = 0 THEN
        v_importe := NULL;
    ELSE
        v_importe := p_importe;
    end if;
    
    --Verificar el dato opcional de detalle
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
        RAISE_APPLICATION_ERROR(-20001, 'El id_cliente no existe.');
        RETURN;
    end if;

    -- Verificar que exista el id_pro_ser
    SELECT COUNT(*) INTO v_id_pro_ser_exist
    FROM PRO_SER
    WHERE ID_PRO_SER = p_id_pro_ser;

    IF v_id_pro_ser_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id de producto o servicio no existe.');
        RETURN;
    end if;

    SELECT TIPO INTO v_tipo_pro_ser
    FROM PRO_SER
    WHERE ID_PRO_SER = p_id_pro_ser;

    --Si es un producto(2) no debe ser nulo
    IF v_tipo_pro_ser = 2 AND (v_importe IS NULL OR v_importe <= 0) THEN
        raise_application_error(-20001, 'El importe es obligatorio para un producto y debe ser mayor a 0.');
        RETURN;
    end if;

    IF v_tipo_pro_ser = 1 AND v_importe IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El importe debe ser nulo para un servicio.');
        RETURN;
    end if;

    -- Insertar en la tabla
    INSERT INTO COMPRA (ID_COMPRA, FECHA, IMPORTE, DETALLE, ID_PRO_SER, ID_CLIENTE)
    VALUES (p_id_compra, v_fecha, v_importe, v_detalle, p_id_pro_ser, p_id_cliente);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Compra asignada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar la compra: ' || SQLERRM);
        ROLLBACK;

end;
/

