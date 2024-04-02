create PROCEDURE registrarCuenta(
    p_id_cuenta IN NUMBER,
    p_monto_apertura IN NUMBER,
    p_saldo IN NUMBER,
    p_descripcion IN VARCHAR2,
    p_fecha_apertura IN VARCHAR2,
    p_detalle IN VARCHAR2,
    p_id_tcuenta IN NUMBER,
    p_id_cliente IN NUMBER
) AS
    v_tipo_cuenta_exists NUMBER;
    v_id_cliente_exists NUMBER;
    v_fecha_apertura DATE;
    v_detalle VARCHAR2(100);
BEGIN
     -- Verificar si el tipo de cliente existe
    SELECT COUNT(*) INTO v_tipo_cuenta_exists
    FROM TIPO_CUENTA
    WHERE ID_TCUENTA = p_id_tcuenta;

    IF v_tipo_cuenta_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo de cuenta no existe.');
        RETURN;
    end if;

    SELECT COUNT(*) INTO v_id_cliente_exists
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id del cliente no existe.');
        RETURN;
    end if;

    IF p_monto_apertura != p_saldo THEN
        RAISE_APPLICATION_ERROR(-20001,'El saldo inicial debe ser igual al monto de apertura.');
        RETURN;
    end if;
     
    IF p_descripcion IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'La descripcion es obligatoria.');
        RETURN;
    end if;

    IF p_fecha_apertura IS NULL THEN
        v_fecha_apertura := SYSDATE;
    ELSE
        BEGIN
            v_fecha_apertura := TO_DATE(p_fecha_apertura, 'DD/MM/YYYY HH24:MI:SS');
        EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha final no tiene el formato correcto.');
            RETURN;
        end;
    end if;
    
    IF p_detalle = '' THEN
        v_detalle := NULL;
    ELSE
        v_detalle := p_detalle;
    end if;
     
    --InserTar la cuenta
    INSERT INTO CUENTA (ID_CUENTA, MONTO_APERTURA, SALDO, DESCRIPCION, FECHA_APERTURA ,DETALLE, ID_TCUENTA, ID_CLIENTE)
    VALUES (p_id_cuenta, p_monto_apertura, p_saldo, p_descripcion, v_fecha_apertura ,v_detalle, p_id_tcuenta, p_id_cliente);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Cuenta registrada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar la cuenta: ' || SQLERRM);
        ROLLBACK;
end;
/

