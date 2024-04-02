create PROCEDURE registrarCliente(
    p_id_cliente IN NUMBER,
    p_nombre IN VARCHAR2,
    p_apellido IN VARCHAR2,
    p_telefonos IN VARCHAR2,
    p_correos IN VARCHAR2,
    p_usuario IN VARCHAR2,
    p_contrasena IN VARCHAR2,
    p_id_tcliente IN NUMBER
) AS
    v_telefonos_arr DBMS_UTILITY.LNAME_ARRAY;
    v_correos_arr DBMS_UTILITY.LNAME_ARRAY;
    v_tipo_cliente_exists NUMBER;
BEGIN
    -- Verificar si el tipo de cliente existe
    SELECT COUNT(*) INTO v_tipo_cliente_exists
    FROM TIPO_CLIENTE
    WHERE ID_TCLIENTE = p_id_tcliente;

    IF v_tipo_cliente_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo de cliente no existe.');
        RETURN;
    end if;

    --VERIFICAR QUE LOS CAMPOS NO VENGAN NULL
    IF p_nombre IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre es un campo obligatorio');
        RETURN;
    end if;

    IF p_apellido IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El apellido es un campo obligatorio');
        RETURN;
    end if;

    IF p_telefonos IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El/Los numero(s) de telefono es/son obligatorio(s).');
        RETURN;
    end if;

    IF p_correos IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El/Los correo(s) es/son obligatorio(s).');
        RETURN;
    end if;

    IF p_usuario IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre de usuario es obligatorio.');
        RETURN;
    end if;

    IF p_contrasena IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'La contrasena es obligatoria.');
    end if;

    -- Separa los numeros y correos
    v_telefonos_arr := SPLIT_STRING(p_telefonos, '-');
    v_correos_arr := SPLIT_STRING(p_correos, '|');

    -- Insertar el cliente
    INSERT INTO CLIENTE (ID_CLIENTE, NOMBRE, APELLIDO, USUARIO, CONTRASENA, ID_TCLIENTE)
    VALUES (p_id_cliente, p_nombre, p_apellido, p_usuario, p_contrasena, p_id_tcliente);

    -- Insertar los numeros de telefono en la tabla telefono
    FOR i in 1..v_telefonos_arr.COUNT LOOP
        INSERT INTO TELEFONO (NUMERO, ID_CLIENTE)
        VALUES (v_telefonos_arr(i),p_id_cliente);
    end loop;

    -- Insertar los correos electronicos en la tabla correo
    FOR j IN 1..v_correos_arr.COUNT LOOP
        INSERT INTO CORREO (DIRECCION, ID_CLIENTE)
        VALUES (v_correos_arr(j), p_id_cliente);
    end loop;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Cliente registrado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar el cliente: ' || SQLERRM);
        ROLLBACK;
end;
/

