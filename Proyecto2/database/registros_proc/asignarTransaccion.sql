create PROCEDURE asignarTransaccion(
    p_fecha_str IN VARCHAR2,    
    p_detalle IN VARCHAR2,
    p_id_ttrans IN NUMBER,
    p_id_accion IN NUMBER,
    p_id_cuenta IN NUMBER
) AS
    v_fecha DATE;
    v_id_ttrans_exist NUMBER;
    v_id_accion_exist NUMBER;
    v_id_cuenta_exist NUMBER;
    v_id_cliente_accion NUMBER;
    v_id_pro_ser NUMBER;
    v_monto_accion NUMBER;
    v_id_cliente_cuenta NUMBER;
    v_saldo_cuenta NUMBER;
    v_detalle VARCHAR2(40);
BEGIN
    --Convertir la cadena de fecha a tipo fecha
    IF p_fecha_str IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: La fecha es un campo obligatorio.');
        RETURN;
    end if;

    BEGIN
        v_fecha := TO_DATE(p_fecha_str,'DD/MM/YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha no tiene el formato correcto.');
            RETURN;
    END;

    --Verificar el campo opcional de detalle
    IF p_detalle = '' THEN
        v_detalle := NULL;
    ELSE
        v_detalle := p_detalle;
    end if;

    --Validar que exista el tipo de transaccion
    SELECT COUNT(*) INTO v_id_ttrans_exist
    FROM TIPO_TRANS
    WHERE ID_TTRANS = p_id_ttrans;

    IF v_id_ttrans_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo de transaccion no existe.');
        RETURN;
    end if;

    -- CON EL TIPO DE TRANSACCION VERIFICAR SI EXISTE EL ID_ACCION
    -- 1 COMPRA
    -- 2 DEPOSITO
    -- 3 DEBITO

    IF p_id_ttrans = 1 THEN
        SELECT COUNT(*)INTO v_id_accion_exist
        FROM COMPRA
        WHERE ID_COMPRA = p_id_accion;
        
        IF v_id_accion_exist = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El ID de la accion realizada no existe.');
            RETURN;
        end if;
        
        SELECT ID_CLIENTE, IMPORTE, ID_PRO_SER INTO v_id_cliente_accion, v_monto_accion, v_id_pro_ser
        FROM COMPRA
        WHERE ID_COMPRA = p_id_accion
        GROUP BY ID_CLIENTE,IMPORTE, ID_PRO_SER;
        
    ELSIF p_id_ttrans = 2 THEN
        SELECT COUNT(*) INTO v_id_accion_exist
        FROM DEPOSITO
        WHERE ID_DEPOSITO = p_id_accion;
        
        IF v_id_accion_exist = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El ID de la accion realizada no existe.');
            RETURN;
        end if;
        
        SELECT COUNT(*), ID_CLIENTE, MONTO INTO v_id_accion_exist, v_id_cliente_accion, v_monto_accion
        FROM DEPOSITO
        WHERE ID_DEPOSITO = p_id_accion
        GROUP BY ID_CLIENTE, MONTO;
    ELSIF p_id_ttrans = 3 THEN
        SELECT COUNT(*) INTO v_id_accion_exist
        FROM DEBITO
        WHERE ID_DEBITO = p_id_accion;
        
        IF v_id_accion_exist = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El ID de la accion realizada no existe.');
            RETURN;
        end if;
        
        SELECT COUNT(*), ID_CLIENTE, MONTO INTO v_id_accion_exist, v_id_cliente_accion,v_monto_accion
        FROM DEBITO
        WHERE ID_DEBITO = p_id_accion
        GROUP BY ID_CLIENTE,MONTO;
    end if;
    
    IF v_monto_accion IS NULL AND p_id_ttrans = 1 THEN
        SELECT COSTO INTO v_monto_accion
        FROM PRO_SER
        WHERE ID_PRO_SER = v_id_pro_ser;
    end if;

    SELECT COUNT(*) INTO v_id_cuenta_exist
    FROM CUENTA
    WHERE ID_CUENTA = p_id_cuenta;

    IF v_id_cuenta_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El numero de cuenta no existe.');
        RETURN;
    end if;
    
    SELECT ID_CLIENTE, SALDO INTO v_id_cliente_cuenta, v_saldo_cuenta
    FROM CUENTA
    WHERE ID_CUENTA = p_id_cuenta
    GROUP BY ID_CLIENTE, SALDO;


    IF v_id_cliente_cuenta != v_id_cliente_accion THEN
        RAISE_APPLICATION_ERROR(-20001, 'La cuenta no corresponde al cliente que hizo la accion.');
        RETURN;
    end if;

    IF p_id_ttrans != 2 THEN
        IF v_saldo_cuenta < v_monto_accion THEN
            RAISE_APPLICATION_ERROR(-20001, 'El saldo de la cuenta no es suficiente para completar la transaccion.');
            RETURN;
        end if;

        UPDATE CUENTA
        SET SALDO = SALDO - v_monto_accion
        WHERE ID_CUENTA = p_id_cuenta;
    ELSE
        UPDATE CUENTA
        SET SALDO = SALDO + v_monto_accion
        WHERE ID_CUENTA = p_id_cuenta;
    end if;

    --INSERTAR LOS VALORES EN LA TRANSACCION

    IF p_id_ttrans = 1 THEN
        INSERT INTO TRANSACCION (FECHA, DETALLE, ID_TTRANS, ID_DEPOSITO, ID_DEBITO, ID_COMPRA, ID_CUENTA)
        VALUES (v_fecha, v_detalle, p_id_ttrans, NULL,NULL,p_id_accion,p_id_cuenta);
    ELSIF p_id_ttrans = 2 THEN
        INSERT INTO TRANSACCION (FECHA, DETALLE, ID_TTRANS, ID_DEPOSITO, ID_DEBITO, ID_COMPRA, ID_CUENTA)
        VALUES (v_fecha, v_detalle,p_id_ttrans,p_id_accion,NULL,NULL,p_id_cuenta);
    ELSIF p_id_ttrans = 3 THEN
        INSERT INTO TRANSACCION (FECHA, DETALLE, ID_TTRANS, ID_DEPOSITO, ID_DEBITO, ID_COMPRA, ID_CUENTA)
        VALUES (v_fecha,v_detalle,p_id_ttrans,NULL,p_id_accion,NULL,p_id_cuenta);
    end if;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transaccion asignada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar la transaccion: ' || SQLERRM);
        ROLLBACK;
end;
/

