create PROCEDURE consultarMovsCliente(
    p_id_cliente IN NUMBER
) AS
    v_json_response CLOB;
    v_cliente_exist NUMBER;
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

    v_json_response := '[' || CHR(10);
    FOR mov IN (
        SELECT trans.ID_TRANSACCION, trans.ID_TTRANS as tipo_transaccion,
               ttrans.NOMBRE AS tipo_servicio,
               COALESCE(com.IMPORTE,ps.COSTO, dep.MONTO, deb.MONTO) AS monto,
               trans.ID_CUENTA as id_cuenta,
               tcta.NOMBRE as tipo_cuenta
        FROM TRANSACCION trans
        LEFT JOIN COMPRA com ON trans.ID_COMPRA = com.ID_COMPRA
        LEFT JOIN PRO_SER ps ON com.ID_PRO_SER = ps.ID_PRO_SER
        LEFT JOIN DEPOSITO dep ON trans.ID_DEPOSITO = dep.ID_DEPOSITO
        LEFT JOIN DEBITO deb ON trans.ID_DEBITO = deb.ID_DEBITO
        JOIN TIPO_TRANS ttrans ON trans.ID_TTRANS = ttrans.ID_TTRANS
        JOIN CUENTA cta ON trans.ID_CUENTA = cta.ID_CUENTA
        JOIN TIPO_CUENTA tcta ON cta.ID_TCUENTA = tcta.ID_TCUENTA
        WHERE cta.ID_CLIENTE = p_id_cliente
    ) LOOP
        v_json_response := v_json_response || '{' || CHR(10) || '"Id_Transaccion": ' || mov.id_transaccion || ',' || CHR(10)
                        || ' "Tipo_Transaccion": ' || mov.tipo_transaccion || ',' || CHR(10)
                        || ' "Monto": ' || mov.monto || ',' || CHR(10)
                        || ' "Tipo_Servicio": "' || mov.tipo_servicio || '",' || CHR(10)
                        || ' "Id_Cuenta": ' || mov.id_cuenta || ',' || CHR(10)
                        || ' "Tipo_Cuenta": "' || mov.tipo_cuenta || '"' || CHR(10) || '},' || CHR(10);
    end loop;

     IF v_json_response = '[' || CHR(10) THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron movimientos con el cliente');
        RETURN;
    end if;

    v_json_response := RTRIM(v_json_response, ',' || CHR(10)) || CHR(10) || ']';

    DBMS_OUTPUT.PUT_LINE(v_json_response);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al consultar la información del cliente: ' || SQLERRM);
        ROLLBACK;
end;
/

