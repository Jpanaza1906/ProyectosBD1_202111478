create PROCEDURE consultarTipoCuentas(
    p_id_tcuenta IN NUMBER
) AS
    v_tipo_cuenta NUMBER;
    v_nombre_cuenta VARCHAR2(40);
    v_cantidad_clientes NUMBER;
    v_tipo_exist NUMBER;
BEGIN
    --Mostrar error si no existe el tipo de cuenta
    SELECT COUNT(*) INTO v_tipo_exist
    FROM TIPO_CUENTA
    WHERE ID_TCUENTA = p_id_tcuenta;

    IF v_tipo_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: No se encontro el tipo de cuenta con el ID especificado.');
        RETURN;
    end if;

    SELECT ID_TCUENTA, NOMBRE INTO v_tipo_cuenta, v_nombre_cuenta
    FROM TIPO_CUENTA
    WHERE ID_TCUENTA = p_id_tcuenta;

    SELECT COUNT(*) INTO v_cantidad_clientes
    FROM (
        SELECT DISTINCT  ID_CLIENTE
        FROM CUENTA
        WHERE ID_TCUENTA = p_id_tcuenta
         );

    -- Imprimir resultados en formato JSON
    DBMS_OUTPUT.PUT_LINE('{
        "Id_Tipo_Cuenta": ' || v_tipo_cuenta || ',
        "Nombre_Cuenta": "' || v_nombre_cuenta || '",
        "Cantidad_Clientes": "' || v_cantidad_clientes || '"
    }');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al consultar la información de los tipos de cuenta: ' || SQLERRM);
        ROLLBACK;
end;
/

