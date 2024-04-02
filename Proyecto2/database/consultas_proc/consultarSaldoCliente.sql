create PROCEDURE consultarSaldoCliente(
    p_no_cuenta IN NUMBER
) AS
    v_nombre_cliente VARCHAR2(40);
    v_id_cliente NUMBER;
    v_tipo_cliente VARCHAR2(40);
    v_tipo_cuenta VARCHAR2(40);
    v_saldo_cuenta NUMBER;
    v_saldo_apertura NUMBER;
    v_cta_exist NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cta_exist
    FROM CUENTA
    WHERE ID_CUENTA = p_no_cuenta;
    
    IF v_cta_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: No se encontro la cuenta con el No. Cuenta');
        RETURN;
    end if;
    
    -- Obtener el nombre del cliente
    SELECT cli.ID_CLIENTE, cli.NOMBRE INTO v_id_cliente,v_nombre_cliente
    FROM CLIENTE cli
    JOIN CUENTA cta ON cli.ID_CLIENTE = cta.ID_CLIENTE
    WHERE cta.ID_CUENTA = p_no_cuenta;

    --Obtener el tipo de cliente
    SELECT tcli.NOMBRE INTO v_tipo_cliente
    FROM CLIENTE cli
    JOIN TIPO_CLIENTE tcli ON cli.ID_TCLIENTE = tcli.ID_TCLIENTE
    WHERE cli.ID_CLIENTE = v_id_cliente;

    --Obtener el tipo de cuenta
    SELECT tcta.NOMBRE INTO v_tipo_cuenta
    FROM TIPO_CUENTA tcta
    JOIN CUENTA cta ON tcta.ID_TCUENTA = cta.ID_TCUENTA
    WHERE cta.ID_CUENTA = p_no_cuenta;

    --Obtener el saldo de la cuenta
    SELECT SALDO into v_saldo_cuenta
    FROM CUENTA
    WHERE ID_CUENTA = p_no_cuenta;

    --Obtener el saldo de apertura de la cuenta
    SELECT MONTO_APERTURA INTO v_saldo_apertura
    FROM CUENTA
    WHERE ID_CUENTA = p_no_cuenta;

    -- Imprimir resultados en formato JSON
    DBMS_OUTPUT.PUT_LINE('{
        "Nombre_Cliente": "' || v_nombre_cliente || '",
        "Tipo_Cliente": "' || v_tipo_cliente || '",
        "Tipo_Cuenta": "' || v_tipo_cuenta || '",
        "Saldo_Cuenta": ' || v_saldo_cuenta || ',
        "Saldo_Apertura": ' || v_saldo_apertura || '
    }');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al consultar la información de la cuenta: ' || SQLERRM);
        ROLLBACK;
end;
/

