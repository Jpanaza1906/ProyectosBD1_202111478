-- PROCEDIMIENTO PARA REGISTRAR LOS TIPOS
CREATE OR REPLACE PROCEDURE registrarTipoTransaccion(
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2
) AS
BEGIN
    --Insertar el tipo de cliente
    INSERT INTO TIPO_TRANS (NOMBRE, DESCRIPCION)
    VALUES (p_nombre, p_descripcion);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Tipo de transaccion registrado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar el tipo de transaccion: ' || SQLERRM);
        ROLLBACK;

end;
/
--Funcion PARA DIVIDIR LA STRING
CREATE OR REPLACE FUNCTION split_string(
    p_string IN VARCHAR2,
    p_delimiter IN VARCHAR2
) RETURN DBMS_UTILITY.LNAME_ARRAY IS
    l_array DBMS_UTILITY.LNAME_ARRAY;
    l_index PLS_INTEGER := 1;
    l_cont PLS_INTEGER := 1;
BEGIN
    FOR i IN 1..LENGTH(p_string) LOOP
        IF SUBSTR(p_string, i, 1) = p_delimiter THEN
            l_index := l_index + 1;
            l_cont := 1;
        ELSE
            IF l_cont = 1 THEN
                l_array(l_index) := '';
            end if;
            l_array(l_index) := l_array(l_index) || SUBSTR(p_string, i, 1);
            l_cont := l_cont + 1;
        END IF;
    END LOOP;
    RETURN l_array;
END split_string;
/

-- PROCEDIMIENTO PARA REGISTRAR CLIENTE

CREATE OR REPLACE PROCEDURE registrarCliente(
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
    end if;

    -- Separa los numeros y correos
    v_telefonos_arr := SPLIT_STRING(p_telefonos, '-');
    v_correos_arr := SPLIT_STRING(p_correos, '-');

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

-- PROCEDIMIENTO PARA CREAR CUENTA

CREATE OR REPLACE PROCEDURE registrarCuenta(
    p_id_cuenta IN NUMBER,
    p_monto_apertura IN NUMBER,
    p_saldo IN NUMBER,
    p_descripcion IN VARCHAR2,
    p_id_tcuenta IN NUMBER,
    p_id_cliente IN NUMBER,
    p_detalle IN VARCHAR2 DEFAULT NULL
) AS
    v_tipo_cuenta_exists NUMBER;
    v_id_cliente_exists NUMBER;
BEGIN
     -- Verificar si el tipo de cliente existe
    SELECT COUNT(*) INTO v_tipo_cuenta_exists
    FROM TIPO_CUENTA
    WHERE ID_TCUENTA = p_id_tcuenta;

    IF v_tipo_cuenta_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo de cuenta no existe.');
    end if;

    SELECT COUNT(*) INTO v_id_cliente_exists
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id del cliente no existe.');
    end if;
    --InserTar la cuenta
    INSERT INTO CUENTA (ID_CUENTA, MONTO_APERTURA, SALDO, DESCRIPCION, DETALLE, ID_TCUENTA, ID_CLIENTE)
    VALUES (p_id_cuenta, p_monto_apertura, p_saldo, p_descripcion, p_detalle, p_id_tcuenta, p_id_cliente);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Cuenta registrada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar la cuenta: ' || SQLERRM);
        ROLLBACK;
end;
/

-- PROCEDIMIENTO PARA CREAR PRODUCTO O SERVICIO

CREATE OR REPLACE PROCEDURE crearProductoServicio(
    p_id_pro_ser IN NUMBER,
    p_tipo IN NUMBER,
    p_descripcion IN VARCHAR2,
    p_costo IN NUMBER DEFAULT NULL
) AS
BEGIN
    INSERT INTO PRO_SER (ID_PRO_SER, TIPO, COSTO, DESCRIPCION)
    VALUES (p_id_pro_ser, p_tipo, p_costo, p_descripcion);

    COMMIT;
    IF p_tipo = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Servicio registrado correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Producto registrado correctamente.');
    end if;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar el producto o servicio: ' || SQLERRM);
        ROLLBACK;
end;
/

-- REALIZAR UNA COMPRA

CREATE OR REPLACE PROCEDURE realizarCompra(
    p_id_compra IN NUMBER,
    p_fecha_str IN VARCHAR2,
    p_id_pro_ser IN NUMBER,
    p_id_cliente IN NUMBER,
    p_importe IN NUMBER DEFAULT NULL,
    p_detalle IN VARCHAR2 DEFAULT NULL
) AS
    v_fecha DATE;
    v_id_cliente_exist NUMBER;
    v_id_pro_ser_exist NUMBER;
    v_tipo_pro_ser NUMBER;
BEGIN
    --Convertir la cadena de fecha a fecha
    v_fecha := TO_DATE(p_fecha_str, 'MM/DD/YYYY');

    -- Verificar que exista el id
    SELECT COUNT(*) INTO v_id_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id_cliente no existe.');
    end if;

    -- Verificar que exista el id_pro_ser
    SELECT COUNT(*) INTO v_id_pro_ser_exist
    FROM PRO_SER
    WHERE ID_PRO_SER = p_id_pro_ser;

    IF v_id_pro_ser_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id de producto o servicio no existe.');
    end if;

    SELECT TIPO INTO v_tipo_pro_ser
    FROM PRO_SER
    WHERE ID_PRO_SER = p_id_pro_ser;

    --Si es un producto(2) no debe ser nulo
    IF v_tipo_pro_ser = 2 AND (p_importe IS NULL OR p_importe < 0) THEN
        raise_application_error(-20001, 'El importe es obligatorio para un producto y debe ser mayor a 0.');
    end if;

    IF v_tipo_pro_ser = 1 AND p_importe IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El importe debe ser nulo para un servicio.');
    end if;

    -- Insertar en la tabla
    INSERT INTO COMPRA (ID_COMPRA, FECHA, IMPORTE, DETALLE, ID_PRO_SER, ID_CLIENTE)
    VALUES (p_id_compra, v_fecha, p_importe, p_detalle, p_id_pro_ser, p_id_cliente);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Compra asignada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar la compra: ' || SQLERRM);
        ROLLBACK;

end;


-- REALIZAR UN DEPOSITO

CREATE OR REPLACE PROCEDURE realizarDeposito(
    p_id_deposito IN NUMBER,
    p_fecha_str IN VARCHAR2,
    p_monto IN NUMBER,
    p_id_cliente in NUMBER,
    p_detalle IN VARCHAR2 DEFAULT NULL
) AS
    v_fecha DATE;
    v_id_cliente_exist NUMBER;
BEGIN
    --Convertir la cadena de fecha a una fecha
    v_fecha := TO_DATE(p_fecha_str, 'MM/DD/YYYY');

    -- Verificar que exista el id
    SELECT COUNT(*) INTO v_id_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id_cliente no existe.');
    end if;

    -- Verificar que el monto sea positivo
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El monto del deposito debe ser mayor a 0.');
    end if;

    --Insertar los valores en deposito
    INSERT INTO DEPOSITO (ID_DEPOSITO, FECHA, MONTO, DETALLE, ID_CLIENTE)
    VALUES (p_id_deposito, v_fecha, p_monto, p_detalle, p_id_cliente);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Deposito asignado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar el deposito: ' || SQLERRM);
        ROLLBACK;
end;
/
-- REALIZAR UN DEBITO

CREATE OR REPLACE PROCEDURE realizarDebito(
    p_id_debito IN NUMBER,
    p_fecha_str IN VARCHAR2,
    p_monto IN NUMBER,
    p_id_cliente IN NUMBER,
    p_detalle IN VARCHAR2 DEFAULT NULL
) AS
    v_fecha DATE;
    v_id_cliente_exist NUMBER;
BEGIN
    --Convertir la cadena de fecha a tipo fecha
    v_fecha := TO_DATE(p_fecha_str, 'MM/DD/YYYY');

    -- Verificar que exista el id
    SELECT COUNT(*) INTO v_id_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La id de cliente no existe.');
    end if;

    -- Verificar que el monto sea mayor a 0
     IF p_monto <= 0 THEN
         RAISE_APPLICATION_ERROR(-20001, 'El monto debe ser mayor a 0.');
     end if;

        -- Insertar el debito
    INSERT INTO DEBITO (ID_DEBITO, FECHA, MONTO, DETALLE, ID_CLIENTE)
    VALUES (p_id_debito, v_fecha, p_monto, p_detalle, p_id_cliente);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Debito asignado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar el debito: ' || SQLERRM);
        ROLLBACK;
end;
/

-- PROCEDIMIENTO PARA REGISTRAR UNA TRANSACCION

CREATE OR REPLACE PROCEDURE asignarTransaccion(
    p_fecha_str IN VARCHAR2,
    p_id_ttrans IN NUMBER,
    p_id_accion IN NUMBER,
    p_id_cuenta IN NUMBER,
    p_detalle IN VARCHAR2 DEFAULT NULL
) AS
    v_fecha DATE;
    v_id_ttrans_exist NUMBER;
    v_id_accion_exist NUMBER;
    v_id_cuenta_exist NUMBER;
    v_id_cliente_accion NUMBER;
    v_monto_accion NUMBER;
    v_id_cliente_cuenta NUMBER;
    v_saldo_cuenta NUMBER;

BEGIN
    --Convertir la cadena de fecha a tipo fecha
    v_fecha := TO_DATE(p_fecha_str,'MM/DD/YYYY');

    --Validar que exista el tipo de transaccion
    SELECT COUNT(*) INTO v_id_ttrans_exist
    FROM TIPO_TRANS
    WHERE ID_TTRANS = p_id_ttrans;

    IF v_id_ttrans_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo de transaccion no existe.');
    end if;

    -- CON EL TIPO DE TRANSACCION VERIFICAR SI EXISTE EL ID_ACCION
    -- 1 COMPRA
    -- 2 DEPOSITO
    -- 3 DEBITO

    IF p_id_ttrans = 1 THEN
        SELECT COUNT(*),ID_CLIENTE, IMPORTE INTO v_id_accion_exist,v_id_cliente_accion, v_monto_accion
        FROM COMPRA
        WHERE ID_COMPRA = p_id_accion
        GROUP BY ID_CLIENTE,IMPORTE;
    ELSIF p_id_ttrans = 2 THEN
        SELECT COUNT(*), ID_CLIENTE, MONTO INTO v_id_accion_exist, v_id_cliente_accion, v_monto_accion
        FROM DEPOSITO
        WHERE ID_DEPOSITO = p_id_accion
        GROUP BY ID_CLIENTE, MONTO;
    ELSIF p_id_ttrans = 3 THEN
        SELECT COUNT(*), ID_CLIENTE, MONTO INTO v_id_accion_exist, v_id_cliente_accion,v_monto_accion
        FROM DEBITO
        WHERE ID_DEBITO = p_id_accion
        GROUP BY ID_CLIENTE,MONTO;
    end if;

    IF v_id_accion_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El ID de la accion realizada no existe.');
    end if;

    SELECT COUNT(*), ID_CLIENTE, SALDO INTO v_id_cuenta_exist, v_id_cliente_cuenta, v_saldo_cuenta
    FROM CUENTA
    WHERE ID_CUENTA = p_id_cuenta
    GROUP BY ID_CLIENTE, SALDO;

    IF v_id_cuenta_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El numero de cuenta no existe.');
    end if;

    IF v_id_cliente_cuenta != v_id_cliente_accion THEN
        RAISE_APPLICATION_ERROR(-20001, 'La cuenta no corresponde al cliente que hizo la accion.');
    end if;

    IF p_id_ttrans != 2 THEN
        IF v_saldo_cuenta < v_monto_accion THEN
            RAISE_APPLICATION_ERROR(-20001, 'El saldo de la cuenta no es suficiente para completar la transaccion.');
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
        VALUES (v_fecha, p_detalle, p_id_ttrans, NULL,NULL,p_id_accion,p_id_cuenta);
    ELSIF p_id_ttrans = 2 THEN
        INSERT INTO TRANSACCION (FECHA, DETALLE, ID_TTRANS, ID_DEPOSITO, ID_DEBITO, ID_COMPRA, ID_CUENTA)
        VALUES (v_fecha, p_detalle,p_id_ttrans,p_id_accion,NULL,NULL,p_id_cuenta);
    ELSIF p_id_ttrans = 3 THEN
        INSERT INTO TRANSACCION (FECHA, DETALLE, ID_TTRANS, ID_DEPOSITO, ID_DEBITO, ID_COMPRA, ID_CUENTA)
        VALUES (v_fecha,p_detalle,p_id_ttrans,NULL,p_id_accion,NULL,p_id_cuenta);
    end if;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transaccion asignada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar la transaccion: ' || SQLERRM);
        ROLLBACK;
end;
/