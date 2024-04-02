create PROCEDURE consultarMovsFechClien(
    p_id_cliente IN NUMBER,
    p_fecha_inicio IN VARCHAR2,
    p_fecha_fin IN VARCHAR2
) AS
    v_json_response CLOB;
    v_cliente_exist NUMBER;
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
BEGIN
    --VERIFICAR SI EXISTE EL ID DEL CLIENTE
    SELECT COUNT(*)
    INTO v_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: No se encontro el cliente con el ID especificado');
        RETURN;
    end if;
    
    IF p_fecha_inicio IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: La fecha de inicio es un parametro obligatorio.');
        RETURN;
    end if;
    
    IF p_fecha_fin IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: La fecha final es un parametro obligatorio.');
        RETURN;
    end if;
    
    BEGIN
        v_fecha_inicio := TO_DATE(p_fecha_inicio, 'DD/MM/YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha de inicio no tiene el formato correcto.');
            RETURN;
    end;
    
    BEGIN
        v_fecha_fin := TO_DATE(p_fecha_fin, 'DD/MM/YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha final no tiene el formato correcto.');
            RETURN;
    end;

    v_json_response := '[' || CHR(10);
    FOR mov IN (
        SELECT trans.ID_TRANSACCION,
               trans.ID_TTRANS as tipo_transaccion,
               ttrans.NOMBRE as tipo_servicio,
               cli.NOMBRE as nombre_cliente,
               cta.ID_CUENTA as id_cuenta,
               tcta.NOMBRE as tipo_cuenta,
               trans.FECHA as fecha,
               COALESCE(com.IMPORTE, ps.COSTO, dep.MONTO, deb.MONTO) AS monto,
               trans.DETALLE as otros_detalles
        FROM TRANSACCION trans
        JOIN TIPO_TRANS ttrans ON trans.ID_TTRANS = ttrans.ID_TTRANS
        JOIN CUENTA cta ON trans.ID_CUENTA = cta.ID_CUENTA
        JOIN TIPO_CUENTA tcta ON cta.ID_TCUENTA = tcta.ID_TCUENTA
        JOIN CLIENTE cli ON cta.ID_CLIENTE = cli.ID_CLIENTE
        LEFT JOIN COMPRA com ON trans.ID_COMPRA = com.ID_COMPRA
        LEFT JOIN PRO_SER ps ON com.ID_PRO_SER = ps.ID_PRO_SER
        LEFT JOIN DEPOSITO dep ON trans.ID_DEPOSITO = dep.ID_DEPOSITO
        LEFT JOIN DEBITO deb ON trans.ID_DEBITO = deb.ID_DEBITO
        WHERE trans.FECHA BETWEEN v_fecha_inicio AND v_fecha_fin
        AND cta.ID_CLIENTE = p_id_cliente
    ) LOOP
        v_json_response := v_json_response || '{' || CHR(10)
                        || '"Id_Transaccion": ' || mov.ID_TRANSACCION || ',' || CHR(10)
                        || '"Tipo_Transaccion": ' || mov.tipo_transaccion || ',' || CHR(10)
                        || '"Tipo_Servicio": "' || mov.tipo_servicio || '",' || CHR(10)
                        || '"Nombre_Cliente": "' || mov.nombre_cliente || '",' || CHR(10)
                        || '"No_Cuenta": ' || mov.id_cuenta || ',' || CHR(10)
                        || '"Tipo_Cuenta": "' || mov.tipo_cuenta || '",' || CHR(10)
                        || '"Fecha": "' || TO_CHAR(mov.fecha, 'DD/MM/YYYY') || '",' || CHR(10)
                        || '"Monto": ' || mov.monto || ',' || CHR(10)
                        || '"Otros_detalles": ' || mov.otros_detalles || ',' || CHR(10)
                        || '},' || CHR(10);

    end loop;

    --Eliminar la utlima coma ya gregar corchetes finales
    IF v_json_response = '[' || CHR(10) THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron registros');
        RETURN;
    end if;
    -- Eliminar la última coma y agregar corchetes finales
    v_json_response := RTRIM(v_json_response, ',' || CHR(10)) || CHR(10) || ']';

    DBMS_OUTPUT.PUT_LINE(v_json_response);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al consultar la información del cliente: ' || SQLERRM);
        ROLLBACK;
end;
/

