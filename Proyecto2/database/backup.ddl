create table PRO_SER
(
    ID_PRO_SER  NUMBER             not null
        constraint PRO_SER_PK
            primary key,
    TIPO        NUMBER             not null,
    COSTO       NUMBER(12, 2),
    DESCRIPCION VARCHAR2(100 char) not null
)
/

create trigger PRO_SER_VTIPO
    before insert or update
    on PRO_SER
    for each row
BEGIN
    IF :NEW.TIPO NOT IN (1,2) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo deber ser 1 para servicio y 2 para producto.');
    end if;
end;
/

create trigger PRO_SER_VCOSTO
    before insert or update
    on PRO_SER
    for each row
BEGIN
    IF :NEW.TIPO = 1 AND (:NEW.COSTO IS NULL OR :NEW.COSTO < 0) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El costo es obligatorio y debe ser mayor a 0 para un servicio.');
    end if;

    IF :NEW.TIPO = 2 AND :NEW.COSTO IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El costo debe ser nulo para un producto.');
    end if;
end;
/

create table TIPO_CLIENTE
(
    ID_TCLIENTE NUMBER             not null
        constraint TIPO_CLIENTE_PK
            primary key,
    NOMBRE      VARCHAR2(40 char)  not null,
    DESCRIPCION VARCHAR2(100 char) not null
)
/

create table CLIENTE
(
    ID_CLIENTE  NUMBER               not null
        constraint CLIENTE_PK
            primary key,
    NOMBRE      VARCHAR2(40 char)    not null,
    APELLIDO    VARCHAR2(40 char)    not null,
    USUARIO     VARCHAR2(40 char)    not null,
    CONTRASENA  VARCHAR2(200 char)   not null,
    FECHA       DATE default sysdate not null,
    ID_TCLIENTE NUMBER               not null
        constraint CLIENTE_TIPO_CLIENTE_FK
            references TIPO_CLIENTE
)
/

create trigger CLIENTE_VNOMBRE
    before insert or update
    on CLIENTE
    for each row
DECLARE
    v_patron VARCHAR2(40) := '^[[:alpha:] ]+$'; -- Expresión regular para letras y espacios
BEGIN
    IF NOT REGEXP_LIKE(:NEW.NOMBRE, v_patron) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre solo debe contener letras y espacios.');
    END IF;
END;
/

create trigger CLIENTE_VAPELLIDO
    before insert or update
    on CLIENTE
    for each row
DECLARE
    v_patron VARCHAR2(40) := '^[[:alpha:] ]+$'; -- Expresión regular para letras y espacios
BEGIN
    IF NOT REGEXP_LIKE(:NEW.APELLIDO, v_patron) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El apellido solo debe contener letras y espacios.');
    END IF;
END;
/

create trigger CLIENTE_VUSUARIO
    before insert or update
    on CLIENTE
    for each row
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM CLIENTE
    WHERE LOWER(USUARIO) = LOWER(:NEW.USUARIO);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre de usuario ya existe en la base de datos.');
    end if;
end;
/

create trigger CLIENTE_VCONTRASENA
    before insert or update
    on CLIENTE
    for each row
DECLARE
    v_hash varchar2(200);
BEGIN
    -- se genera el hash de la contrasena utilizando sha-256
    v_hash := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(:NEW.CONTRASENA),5);

    -- almacenar el hash en el campo de contrasena
    :NEW.CONTRASENA := v_hash;
end;
/

create table COMPRA
(
    ID_COMPRA  NUMBER not null
        constraint COMPRA_PK
            primary key,
    FECHA      DATE   not null,
    IMPORTE    NUMBER(12, 2),
    DETALLE    VARCHAR2(40 char),
    ID_PRO_SER NUMBER not null
        constraint COMPRA_PRO_SER_FK
            references PRO_SER,
    ID_CLIENTE NUMBER not null
        constraint COMPRA_CLIENTE_FK
            references CLIENTE
)
/

create table CORREO
(
    ID_CORREO  NUMBER            not null
        constraint CORREO_PK
            primary key,
    DIRECCION  VARCHAR2(40 char) not null,
    ID_CLIENTE NUMBER            not null
        constraint CORREO_CLIENTE_FK
            references CLIENTE
)
/

create trigger CORREO_ID_TRIGGER
    before insert or update
    on CORREO
    for each row
BEGIN
    SELECT NVL(MAX(ID_CORREO), 0) + 1 INTO :NEW.ID_CORREO FROM CORREO; -- Obtener el último ID y sumar 1
END;
/

create trigger CORREO_VDIRECCION
    before insert or update
    on CORREO
    for each row
DECLARE
    v_patron VARCHAR2(100) := '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
BEGIN
    IF NOT REGEXP_LIKE(:NEW.DIRECCION, v_patron) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El correo electrónico no tiene un formato válido.');
    END IF;
END;
/

create table DEBITO
(
    ID_DEBITO  NUMBER        not null
        constraint DEBITO_PK
            primary key,
    FECHA      DATE          not null,
    MONTO      NUMBER(12, 2) not null,
    DETALLE    VARCHAR2(40 char),
    ID_CLIENTE NUMBER        not null
        constraint DEBITO_CLIENTE_FK
            references CLIENTE
)
/

create table DEPOSITO
(
    ID_DEPOSITO NUMBER        not null
        constraint DEPOSITO_PK
            primary key,
    FECHA       DATE          not null,
    MONTO       NUMBER(12, 2) not null,
    DETALLE     VARCHAR2(40 char),
    ID_CLIENTE  NUMBER        not null
        constraint DEPOSITO_CLIENTE_FK
            references CLIENTE
)
/

create table TELEFONO
(
    ID_TELEFONO NUMBER            not null
        constraint TELEFONO_PK
            primary key,
    NUMERO      VARCHAR2(12 char) not null,
    ID_CLIENTE  NUMBER            not null
        constraint TELEFONO_CLIENTE_FK
            references CLIENTE
)
/

create trigger TELEFONO_ID_TRIGGER
    before insert or update
    on TELEFONO
    for each row
BEGIN
    SELECT NVL(MAX(ID_TELEFONO), 0) + 1 INTO :NEW.ID_TELEFONO FROM TELEFONO; -- Obtener el último ID y sumar 1
END;
/

create trigger TELEFONO_VNUMERO
    before insert or update
    on TELEFONO
    for each row
BEGIN
    IF LENGTH(:NEW.NUMERO) < 8 THEN
        RAISE_APPLICATION_ERROR(-20001,'El numero de telefono debe tener al menos 8 digitos.');
    ELSIF LENGTH(:NEW.NUMERO) > 8 THEN
        :NEW.NUMERO := SUBSTR(:NEW.NUMERO, -8);
    end if;
end;
/

create trigger TCLIENTE_ID_TRIGGER
    before insert or update
    on TIPO_CLIENTE
    for each row
BEGIN
    SELECT NVL(MAX(ID_TCLIENTE), 0) + 1 INTO :NEW.ID_TCLIENTE FROM TIPO_CLIENTE; -- Obtener el último ID y sumar 1
END;
/

create trigger TCLIENTE_VDESCRIP
    before insert or update
    on TIPO_CLIENTE
    for each row
DECLARE
    v_patron VARCHAR2(40) := '^[[:alpha:] .,]+$'; -- Expresión regular para letras y espacios
BEGIN
    IF NOT REGEXP_LIKE(:NEW.DESCRIPCION, v_patron) THEN
        RAISE_APPLICATION_ERROR(-20001, 'La descripcion puede tener unicamente letras, espacios, comas y puntos.');
    END IF;
END;
/

create table TIPO_CUENTA
(
    ID_TCUENTA  NUMBER             not null
        constraint TIPO_CUENTA_PK
            primary key,
    NOMBRE      VARCHAR2(40 char)  not null,
    DESCRIPCION VARCHAR2(150 char) not null
)
/

create table CUENTA
(
    ID_CUENTA      NUMBER               not null
        constraint CUENTA_PK
            primary key,
    MONTO_APERTURA NUMBER(12, 2)        not null,
    SALDO          NUMBER(12, 2)        not null,
    DESCRIPCION    VARCHAR2(50 char)    not null,
    FECHA_APERTURA DATE default sysdate not null,
    DETALLE        VARCHAR2(100 char),
    ID_TCUENTA     NUMBER               not null
        constraint CUENTA_TIPO_CUENTA_FK
            references TIPO_CUENTA,
    ID_CLIENTE     NUMBER               not null
        constraint CUENTA_CLIENTE_FK
            references CLIENTE
)
/

create trigger CUENTA_VMONTO
    before update
    on CUENTA
    for each row
BEGIN    
    IF :OLD.MONTO_APERTURA != :NEW.MONTO_APERTURA THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede modificar el monto de apertura.');
    end if;
end;
/

create trigger CUENTA_VSALDO
    before insert or update
    on CUENTA
    for each row
BEGIN
    IF :NEW.SALDO < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El saldo debe ser mayor o igual a 0');
    end if;
    IF :NEW.MONTO_APERTURA <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El monto de apertura debe ser mayor o igual a 0');
    end if;
end;
/

create trigger TCUENTA_ID_TRIGGER
    before insert or update
    on TIPO_CUENTA
    for each row
BEGIN
    SELECT NVL(MAX(ID_TCUENTA), 0) + 1 INTO :NEW.ID_TCUENTA FROM TIPO_CUENTA; -- Obtener el último ID y sumar 1
END;
/

create table TIPO_TRANS
(
    ID_TTRANS   NUMBER             not null
        constraint TIPO_TRANS_PK
            primary key,
    NOMBRE      VARCHAR2(40 char)  not null,
    DESCRIPCION VARCHAR2(100 char) not null
)
/

create trigger TTRANS_ID_TRIGGER
    before insert or update
    on TIPO_TRANS
    for each row
BEGIN
    SELECT NVL(MAX(ID_TTRANS), 0) + 1 INTO :NEW.ID_TTRANS FROM TIPO_TRANS; -- Obtener el último ID y sumar 1
END;
/

create table TRANSACCION
(
    ID_TRANSACCION NUMBER not null
        constraint TRANSACCION_PK
            primary key,
    FECHA          DATE   not null,
    DETALLE        VARCHAR2(40 char),
    ID_TTRANS      NUMBER not null
        constraint TRANSACCION_TIPO_TRANS_FK
            references TIPO_TRANS,
    ID_DEPOSITO    NUMBER
        constraint TRANSACCION_DEPOSITO_FK
            references DEPOSITO,
    ID_DEBITO      NUMBER
        constraint TRANSACCION_DEBITO_FK
            references DEBITO,
    ID_COMPRA      NUMBER
        constraint TRANSACCION_COMPRA_FK
            references COMPRA,
    ID_CUENTA      NUMBER not null
        constraint TRANSACCION_CUENTA_FK
            references CUENTA
)
/

create unique index TRANSACCION__IDX
    on TRANSACCION (ID_COMPRA)
/

create unique index TRANSACCION__IDXV1
    on TRANSACCION (ID_DEBITO)
/

create unique index TRANSACCION__IDXV2
    on TRANSACCION (ID_DEPOSITO)
/

create trigger TRANSACCION_ID_TRIGGER
    before insert or update
    on TRANSACCION
    for each row
BEGIN
    SELECT NVL(MAX(ID_TRANSACCION), 0) + 1 INTO :NEW.ID_TRANSACCION FROM TRANSACCION; -- Obtener el último ID y sumar 1
END;
/

create table BITACORA
(
    FECHA       DATE default sysdate,
    DESCRIPCION VARCHAR2(255),
    TIPO        VARCHAR2(10)
)
/

create trigger CLIENTE_INSERT
    after insert
    on CLIENTE
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla CLIENTE.','INSERT');
end;
/

create trigger CLIENTE_UPDATE
    after update
    on CLIENTE
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla CLIENTE.','UPDATE');
end;
/

create trigger CLIENTE_DELETE
    after delete
    on CLIENTE
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla CLIENTE.','DELETE');
end;
/

create trigger COMPRA_INSERT
    after insert
    on COMPRA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla COMPRA.','INSERT');
end;
/

create trigger COMPRA_UPDATE
    after update
    on COMPRA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla COMPRA.','UPDATE');
end;
/

create trigger COMPRA_DELETE
    after delete
    on COMPRA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla COMPRA.','DELETE');
end;
/

create trigger CORREO_INSERT
    after insert
    on CORREO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla CORREO.','INSERT');
end;
/

create trigger CORREO_UPDATE
    after update
    on CORREO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla CORREO.','UPDATE');
end;
/

create trigger CORREO_DELETE
    after delete
    on CORREO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla CORREO.','DELETE');
end;
/

create trigger CUENTA_INSERT
    after insert
    on CUENTA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla CUENTA.','INSERT');
end;
/

create trigger CUENTA_UPDATE
    after update
    on CUENTA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla CUENTA.','UPDATE');
end;
/

create trigger CUENTA_DELETE
    after delete
    on CUENTA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla CUENTA.','DELETE');
end;
/

create trigger DEBITO_INSERT
    after insert
    on DEBITO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla DEBITO.','INSERT');
end;
/

create trigger DEBITO_UPDATE
    after update
    on DEBITO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla DEBITO.','UPDATE');
end;
/

create trigger DEBITO_DELETE
    after delete
    on DEBITO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla DEBITO.','DELETE');
end;
/

create trigger DEPOSITO_INSERT
    after insert
    on DEPOSITO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla DEPOSITO.','INSERT');
end;
/

create trigger DEPOSITO_UPDATE
    after update
    on DEPOSITO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla DEPOSITO.','UPDATE');
end;
/

create trigger DEPOSITO_DELETE
    after delete
    on DEPOSITO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla DEPOSITO.','DELETE');
end;
/

create trigger PRO_SER_INSERT
    after insert
    on PRO_SER
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla PRO_SER.','INSERT');
end;
/

create trigger PRO_SER_UPDATE
    after update
    on PRO_SER
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla PRO_SER.','UPDATE');
end;
/

create trigger PRO_SER_DELETE
    after delete
    on PRO_SER
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla PRO_SER.','DELETE');
end;
/

create trigger TELEFONO_INSERT
    after insert
    on TELEFONO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla TELEFONO.','INSERT');
end;
/

create trigger TELEFONO_UPDATE
    after update
    on TELEFONO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla TELEFONO.','UPDATE');
end;
/

create trigger TELEFONO_DELETE
    after delete
    on TELEFONO
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla TELEFONO.','DELETE');
end;
/

create trigger TIPO_CLIENTE_INSERT
    after insert
    on TIPO_CLIENTE
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla TIPO_CLIENTE.','INSERT');
end;
/

create trigger TIPO_CLIENTE_UPDATE
    after update
    on TIPO_CLIENTE
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla TIPO_CLIENTE.','UPDATE');
end;
/

create trigger TIPO_CLIENTE_DELETE
    after delete
    on TIPO_CLIENTE
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla TIPO_CLIENTE.','DELETE');
end;
/

create trigger TIPO_CUENTA_INSERT
    after insert
    on TIPO_CUENTA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla TIPO_CUENTA.','INSERT');
end;
/

create trigger TIPO_CUENTA_UPDATE
    after update
    on TIPO_CUENTA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla TIPO_CUENTA.','UPDATE');
end;
/

create trigger TIPO_CUENTA_DELETE
    after delete
    on TIPO_CUENTA
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla TIPO_CUENTA.','DELETE');
end;
/

create trigger TIPO_TRANS_INSERT
    after insert
    on TIPO_TRANS
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla TIPO_TRANS.','INSERT');
end;
/

create trigger TIPO_TRANS_UPDATE
    after update
    on TIPO_TRANS
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla TIPO_TRANS.','UPDATE');
end;
/

create trigger TIPO_TRANS_DELETE
    after delete
    on TIPO_TRANS
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla TIPO_TRANS.','DELETE');
end;
/

create trigger TRANSACCION_INSERT
    after insert
    on TRANSACCION
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla TRANSACCION.','INSERT');
end;
/

create trigger TRANSACCION_UPDATE
    after update
    on TRANSACCION
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla TRANSACCION.','UPDATE');
end;
/

create trigger TRANSACCION_DELETE
    after delete
    on TRANSACCION
    for each row
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla TRANSACCION.','DELETE');
end;
/

create PROCEDURE registrarTipoCliente(
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2
) AS
BEGIN
    --Insertar el tipo de cliente
    INSERT INTO TIPO_CLIENTE (NOMBRE, DESCRIPCION)
    VALUES (p_nombre, p_descripcion);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Tipo de cliente registrado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar el tipo de cliente: ' || SQLERRM);
        ROLLBACK;

end;
/

create PROCEDURE registrarTipoCuenta(
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2
) AS
BEGIN
    --Insertar el tipo de cliente
    INSERT INTO TIPO_CUENTA (NOMBRE, DESCRIPCION)
    VALUES (p_nombre, p_descripcion);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Tipo de cuenta registrado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar el tipo de cuenta: ' || SQLERRM);
        ROLLBACK;

end;
/

create PROCEDURE registrarTipoTransaccion(
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

create FUNCTION split_string(
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

create PROCEDURE registrarCuenta(
    p_id_cuenta IN NUMBER,
    p_monto_apertura IN NUMBER,
    p_saldo IN NUMBER,
    p_descripcion IN VARCHAR2,    
    p_detalle IN VARCHAR2,
    p_id_tcuenta IN NUMBER,
    p_id_cliente IN NUMBER
) AS
    v_tipo_cuenta_exists NUMBER;
    v_id_cliente_exists NUMBER;
    v_detalle VARCHAR2(100);
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
    
    IF p_detalle = '' THEN
        v_detalle := NULL;
    ELSE
        v_detalle := p_detalle;
    end if;
     
    --InserTar la cuenta
    INSERT INTO CUENTA (ID_CUENTA, MONTO_APERTURA, SALDO, DESCRIPCION, DETALLE, ID_TCUENTA, ID_CLIENTE)
    VALUES (p_id_cuenta, p_monto_apertura, p_saldo, p_descripcion, v_detalle, p_id_tcuenta, p_id_cliente);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Cuenta registrada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar la cuenta: ' || SQLERRM);
        ROLLBACK;
end;
/

create PROCEDURE crearProductoServicio(
    p_id_pro_ser IN NUMBER,
    p_tipo IN NUMBER,    
    p_costo IN NUMBER,
    p_descripcion IN VARCHAR2
) AS
    v_costo NUMBER;
BEGIN
    if p_costo = 0 THEN
        v_costo := NULL;
    ELSE
        v_costo := p_costo;
    end if;
    
    INSERT INTO PRO_SER (ID_PRO_SER, TIPO, COSTO, DESCRIPCION)
    VALUES (p_id_pro_ser, p_tipo, v_costo, p_descripcion);

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
    v_monto_accion NUMBER;
    v_id_cliente_cuenta NUMBER;
    v_saldo_cuenta NUMBER;
    v_detalle VARCHAR2(40);
BEGIN
    --Convertir la cadena de fecha a tipo fecha
    v_fecha := TO_DATE(p_fecha_str,'DD/MM/YYYY');

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

create PROCEDURE realizarDeposito(
    p_id_deposito IN NUMBER,
    p_fecha_str IN VARCHAR2,
    p_monto IN NUMBER,
    p_detalle IN VARCHAR2,
    p_id_cliente in NUMBER
) AS
    v_fecha DATE;
    v_id_cliente_exist NUMBER;
    v_detalle VARCHAR2(40);
BEGIN
    --Convertir la cadena de fecha a una fecha
    v_fecha := TO_DATE(p_fecha_str, 'DD/MM/YYYY');
    
    -- Verificar el campo opcional de Detalle
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
    end if;

    -- Verificar que el monto sea positivo
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El monto del deposito debe ser mayor a 0.');
    end if;

    --Insertar los valores en deposito
    INSERT INTO DEPOSITO (ID_DEPOSITO, FECHA, MONTO, DETALLE, ID_CLIENTE)
    VALUES (p_id_deposito, v_fecha, p_monto, v_detalle, p_id_cliente);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Deposito asignado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar el deposito: ' || SQLERRM);
        ROLLBACK;
end;
/

create PROCEDURE realizarDebito(
    p_id_debito IN NUMBER,
    p_fecha_str IN VARCHAR2,
    p_monto IN NUMBER,    
    p_detalle IN VARCHAR2,
    p_id_cliente IN NUMBER
) AS
    v_fecha DATE;
    v_id_cliente_exist NUMBER;
    v_detalle VARCHAR2(40);
BEGIN
    --Convertir la cadena de fecha a tipo fecha
    v_fecha := TO_DATE(p_fecha_str, 'DD/MM/YYYY');

    --Verificar el campo opcional de detalle
    
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
        RAISE_APPLICATION_ERROR(-20001, 'La id de cliente no existe.');
    end if;

    -- Verificar que el monto sea mayor a 0
     IF p_monto <= 0 THEN
         RAISE_APPLICATION_ERROR(-20001, 'El monto debe ser mayor a 0.');
     end if;

        -- Insertar el debito
    INSERT INTO DEBITO (ID_DEBITO, FECHA, MONTO, DETALLE, ID_CLIENTE)
    VALUES (p_id_debito, v_fecha, p_monto, v_detalle, p_id_cliente);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Debito asignado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al asignar el debito: ' || SQLERRM);
        ROLLBACK;
end;
/

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
    --Convertir la cadena de fecha a fecha
    v_fecha := TO_DATE(p_fecha_str, 'DD/MM/YYYY');
    
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
    IF v_tipo_pro_ser = 2 AND (v_importe IS NULL OR v_importe < 0) THEN
        raise_application_error(-20001, 'El importe es obligatorio para un producto y debe ser mayor a 0.');
    end if;

    IF v_tipo_pro_ser = 1 AND v_importe IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El importe debe ser nulo para un servicio.');
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
