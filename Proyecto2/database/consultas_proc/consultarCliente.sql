create PROCEDURE consultarCliente(
    p_id_cliente in NUMBER
) AS
    v_nombre_cliente VARCHAR2(80);
    v_fecha_creacion DATE;
    v_usuario VARCHAR2(40);
    v_telefonos VARCHAR2(2000);
    v_correos VARCHAR2(2000);
    v_num_ctas NUMBER;
    v_tipos_cta VARCHAR2(2000);
    v_cliente_exist NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: No se encontro el cliente con el ID especificado');
        RETURN;
    end if;
    
    -- Obtener el nombre completo del cliente
    SELECT NOMBRE || ' ' || APELLIDO INTO v_nombre_cliente
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    -- Obtener la fecha de creacion del cliente
    SELECT FECHA INTO v_fecha_creacion
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    -- Obtener el usuario del cliente
    SELECT USUARIO INTO v_usuario
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    --Obtener los telefonos del cliente
    SELECT LISTAGG(NUMERO, ', ') WITHIN GROUP ( ORDER BY ID_TELEFONO) INTO v_telefonos
    FROM TELEFONO
    WHERE ID_CLIENTE = p_id_cliente;

    --Obtener los correos del cliente
    SELECT LISTAGG(DIRECCION, ', ') WITHIN GROUP ( ORDER BY ID_CORREO) INTO v_correos
    FROM CORREO
    WHERE ID_CLIENTE = p_id_cliente;

    -- Obtener los tipos de cuenta distintos del cliente
    SELECT LISTAGG(tc.nombre, ', ') WITHIN GROUP (ORDER BY tc.nombre) INTO v_tipos_cta
    FROM (
        SELECT DISTINCT tc.nombre
        FROM cuenta c
        JOIN tipo_cuenta tc ON c.id_tcuenta = tc.id_tcuenta
        WHERE c.id_cliente = p_id_cliente
    ) tc;


    -- Obtener el numero de cuentas del cliente
    SELECT COUNT(*) INTO v_num_ctas
    FROM CUENTA
    WHERE ID_CLIENTE = p_id_cliente;
    -- Imprimir resultados en formato JSON
    DBMS_OUTPUT.PUT_LINE('{
        "Id_Cliente": ' || p_id_cliente || ',
        "Nombre_Completo": "' || v_nombre_cliente || '",
        "Fecha_Creacion": "' || TO_CHAR(v_fecha_creacion, 'DD/MM/YYYY HH24:MI:SS') || '",
        "Usuario": "' || v_usuario || '",
        "Telefonos": "' || v_telefonos || '",
        "Correos": "' || v_correos || '",
        "No_Cuentas": ' || v_num_ctas || ',
        "Tipos_Cuenta": "' || v_tipos_cta || '"
    }');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al consultar la información del cliente: ' || SQLERRM);
        ROLLBACK;
end;
/

