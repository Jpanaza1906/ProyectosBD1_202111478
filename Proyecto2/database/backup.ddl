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
    IF :NEW.TIPO = 1 AND (:NEW.COSTO IS NULL OR :NEW.COSTO <= 0) THEN
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
    v_tcl_ant NUMBER;
BEGIN
    --Verificar que no vengan null
    IF p_nombre IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El nombre es un campo obligatorio.');
        RETURN;
    end if;

    IF LENGTH(p_nombre) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001,'El nombre excede el numero maximo de caracteres que es de 40.');
        RETURN;
    end if;
    
    IF p_descripcion IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'La descripcion es un campo obligatorio.');
        RETURN;
    end if;

    IF LENGTH(p_descripcion) > 100 THEN
        RAISE_APPLICATION_ERROR(-20001,'La descripcion excede el numero maximo de caracteres que es de 100.');
        RETURN;
    end if;
    
    SELECT COUNT(*) INTO v_tcl_ant
    FROM TIPO_CLIENTE
    WHERE DESCRIPCION = p_descripcion OR NOMBRE = p_nombre;
    
    IF v_tcl_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'El objeto ya se encuentra en la base de datos');
        return ;
    end if;
    
    
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
    v_tcta_ant NUMBER;
BEGIN
    IF p_nombre IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El nombre es un campo obligatorio.');
        RETURN;
    end if;
    
    IF LENGTH(p_nombre) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001,'El nombre excede el numero maximo de caracteres que es de 40.');
        RETURN;
    end if;

    IF p_descripcion IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'La descripcion es un campo obligatorio.');
        RETURN;
    end if;
    
    IF LENGTH(p_descripcion) > 100 THEN
        RAISE_APPLICATION_ERROR(-20001,'La descripcion excede el numero maximo de caracteres que es de 100.');
        RETURN;
    end if;
    
    SELECT COUNT(*) INTO v_tcta_ant
    FROM TIPO_CUENTA
    WHERE DESCRIPCION = p_descripcion OR NOMBRE = p_nombre;
    
    IF v_tcta_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'El objeto ya se encuentra en la base de datos');
        return ;
    end if;

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
    v_ttran_ant NUMBER;
BEGIN
    IF p_nombre IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El nombre es un campo obligatorio.');
        RETURN;
    end if;
    
    IF LENGTH(p_nombre) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001,'El nombre excede el numero maximo de caracteres que es de 40.');
        RETURN;
    end if;

    IF p_descripcion IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'La descripcion es un campo obligatorio.');
        RETURN;
    end if;
    
    IF LENGTH(p_descripcion) > 100 THEN
        RAISE_APPLICATION_ERROR(-20001,'La descripcion excede el numero maximo de caracteres que es de 100.');
        RETURN;
    end if;
    
    SELECT COUNT(*) INTO v_ttran_ant
    FROM TIPO_TRANS
    WHERE DESCRIPCION = p_descripcion OR NOMBRE = p_nombre;
    
    IF v_ttran_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'El objeto ya se encuentra en la base de datos');
        return ;
    end if;
    
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
    v_id_ant NUMBER;
BEGIN
    IF p_id_cliente = 0 OR p_id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'EL id del cliente no puede venir nulo');
        RETURN;
    end if;

    IF p_id_tcliente = 0 OR p_id_tcliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo de cliente no puede venir nulo');
    end if;

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

    IF LENGTH(p_nombre) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre excede el numero maximo de caracteres que es de 40');
        RETURN;
    end if;

    IF p_apellido IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El apellido es un campo obligatorio');
        RETURN;
    end if;

    IF LENGTH(p_apellido) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El apellido excede el numero maximo de caracteres que es de 40');
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

    IF LENGTH(p_usuario) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El usuario excede el numero maximo de caracteres que es de 40');
        RETURN;
    end if;

    IF p_contrasena IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'La contrasena es obligatoria.');
        RETURN;
    end if;

    IF LENGTH(p_contrasena) > 200 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La contraseña excede el numero maximo de caracteres que es de 200');
        RETURN;
    end if;

    SELECT COUNT(*) INTO v_id_ant
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id de cliente ya existe en la base de datos');
        RETURN;
    end if;
    -- Separa los numeros y correos
    BEGIN
        --Convertir el arreglo de telefonos
        v_telefonos_arr := SPLIT_STRING(p_telefonos, '-');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Los telefonos no tienen un formato correcto, se separan con -');
            RETURN;
    end;
    
     BEGIN
        --Convertir el arreglo de telefonos
        v_correos_arr := SPLIT_STRING(p_correos, '|');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Los correos no tienen un formato correcto, se separan con |');
            RETURN;
    end;

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
    p_fecha_apertura IN VARCHAR2,
    p_detalle IN VARCHAR2,
    p_id_tcuenta IN NUMBER,
    p_id_cliente IN NUMBER
) AS
    v_tipo_cuenta_exists NUMBER;
    v_id_cliente_exists NUMBER;
    v_fecha_apertura DATE;
    v_detalle VARCHAR2(100);
    v_id_ant NUMBER;
BEGIN
    IF p_id_cuenta = 0 OR p_id_cuenta IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id de la cuenta no puede ser nulo');
        RETURN;
    end if;

    IF LENGTH(TO_CHAR(p_id_cuenta)) != 10 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Un numero valido de cuenta debe tener 10 digitos');
        RETURN;
    end if;

    IF p_id_tcuenta = 0 OR p_id_tcuenta IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo de cuente no puede ser nulo');
        RETURN;
    end if;

    IF p_id_cliente = 0 OR p_id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id del cliente no puede ser nulo');
        RETURN;
    end if;

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
     
    --IF p_descripcion IS NULL THEN
    --    RAISE_APPLICATION_ERROR(-20001,'La descripcion es obligatoria.');
    --    RETURN;
    --end if;

    IF LENGTH(p_descripcion) > 50 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La descripcion excede el numero maximo de caracteres que es de 50');
        RETURN;
    end if;

    IF p_fecha_apertura IS NULL THEN
        v_fecha_apertura := SYSDATE;
    ELSE
        BEGIN
            v_fecha_apertura := TO_DATE(p_fecha_apertura, 'DD/MM/YYYY HH24:MI:SS');
        EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha no tiene el formato correcto.');
            RETURN;
        end;
    end if;
    
    IF p_detalle = '' THEN
        v_detalle := NULL;
    ELSE
        v_detalle := p_detalle;
    end if;

    IF LENGTH(p_detalle) > 100 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El detalle excede el numero maximo de caracteres que es de 100');
        RETURN;
    end if;
    
    SELECT COUNT(*) INTO v_id_ant
    FROM CUENTA
    WHERE ID_CUENTA = p_id_cuenta;
    
    IF v_id_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El numero de cuenta ya existe en la base de datos');
        RETURN;
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

create PROCEDURE crearProductoServicio(
    p_id_pro_ser IN NUMBER,
    p_tipo IN NUMBER,    
    p_costo IN NUMBER,
    p_descripcion IN VARCHAR2
) AS
    v_costo NUMBER;
    v_por_ant NUMBER;
BEGIN
    IF LENGTH(p_descripcion) > 100 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La descripcion no puede sobrepasar los 100 caracteres');
        RETURN;
    end if;

    SELECT COUNT(*) INTO v_por_ant
    FROM PRO_SER
    WHERE ID_PRO_SER = p_id_pro_ser OR DESCRIPCION = p_descripcion;
    
    IF v_por_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'El tipo de servicio o producto ya existe en la Base de datos');
        RETURN;
    end if;
    
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
    v_id_pro_ser NUMBER;
    v_monto_accion NUMBER;
    v_id_cliente_cuenta NUMBER;
    v_saldo_cuenta NUMBER;
    v_detalle VARCHAR2(40);
    v_id_acc_ant NUMBER;
BEGIN
    --VALIDACION DE DATOS
    IF LENGTH(p_detalle) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El detalle excede los 40 caracteres.');
        RETURN;
    end if;

    IF LENGTH(TO_CHAR(p_id_cuenta)) != 10 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Un NO. de cuenta valido debe tener 10 digitos');
    end if;

    SELECT COUNT(*) INTO v_id_acc_ant
    FROM TRANSACCION
    WHERE ID_DEPOSITO = p_id_accion OR ID_DEBITO = p_id_accion OR ID_COMPRA = p_id_accion;

    IF v_id_acc_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id de la accion ya esta asociado a una transaccion.');
        RETURN;
    end if;

    --Convertir la cadena de fecha a tipo fecha
    IF p_fecha_str IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'La fecha es un campo obligatorio.');
        RETURN;
    end if;

    BEGIN
        v_fecha := TO_DATE(p_fecha_str,'DD/MM/YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'La fecha no tiene el formato correcto.');
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
            RAISE_APPLICATION_ERROR(-20001, 'El ID de la compra realizada no existe.');
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
            RAISE_APPLICATION_ERROR(-20001, 'El ID del deposito realizado no existe.');
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
            RAISE_APPLICATION_ERROR(-20001, 'El ID del debito realizado no existe.');
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
    v_id_ant NUMBER;
BEGIN
    IF p_id_deposito = 0 OR p_id_deposito IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El id del deposito no puede ser nulo');
        RETURN;
    end if;

    IF p_fecha_str IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: La fecha es un parametro obligatorio.');
        RETURN;
    end if;
    
    BEGIN
        --Convertir la cadena de fecha a fecha
        v_fecha := TO_DATE(p_fecha_str, 'DD/MM/YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha no tiene el formato correcto.');
            RETURN;
    end;
    
    -- Verificar el campo opcional de Detalle
    IF p_detalle = '' THEN
        v_detalle := NULL;
    ELSE
        v_detalle := p_detalle;
    end if;

    IF p_id_cliente = 0 OR p_id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'EL id del cliente no puede ser nulo');
        RETURN ;
    end if;
    
    IF LENGTH(p_detalle) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001,'El detalle excede la cantidad maxima de caracteres, la cual es 40');
        RETURN;
    end if;
    
    SELECT COUNT(*) INTO v_id_ant
    FROM DEPOSITO
    WHERE ID_DEPOSITO = p_id_deposito;
    
    IF v_id_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id del deposito ya existe en la base de datos');
        RETURN;
    end if;




    -- Verificar que exista el id
    SELECT COUNT(*) INTO v_id_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id_cliente no existe.');
        RETURN;
    end if;

    -- Verificar que el monto sea positivo
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El monto del deposito debe ser mayor a 0.');
        RETURN;
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
    v_id_ant NUMBER;
BEGIN
    IF p_id_debito = 0 OR p_id_debito IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'EL id del debito no puede ser nulo');
        RETURN;
    end if;

    IF p_fecha_str IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: La fecha es un parametro obligatorio.');
        RETURN;
    end if;
    
    BEGIN
        --Convertir la cadena de fecha a fecha
        v_fecha := TO_DATE(p_fecha_str, 'DD/MM/YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha no tiene el formato correcto.');
            RETURN;
    end;

    --Verificar el campo opcional de detalle
    
    IF p_detalle = '' THEN
        v_detalle := NULL;
    ELSE
        v_detalle := p_detalle;
    end if;
    
    IF p_id_cliente = 0 OR p_id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id del cliente no puede ser nulo');
        RETURN;
    end if;
    
    IF LENGTH(p_detalle) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001,'El detalle excede la cantidad maxima de caracteres, la cual es 40');
        RETURN;
    end if;
    
    SELECT COUNT(*) INTO v_id_ant
    FROM DEBITO
    WHERE ID_DEBITO = p_id_debito;
    
    IF v_id_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id del debito ya se encuentra en la base de datos');
    end if;

    -- Verificar que exista el id
    SELECT COUNT(*) INTO v_id_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La id de cliente no existe.');
        RETURN;
    end if;

    -- Verificar que el monto sea mayor a 0
     IF p_monto <= 0 THEN
         RAISE_APPLICATION_ERROR(-20001, 'El monto debe ser mayor a 0.');
         RETURN;
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
    v_id_ant NUMBER;
BEGIN
    IF p_id_compra = 0 OR p_id_compra IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id de compra no puede ser nulo');
        RETURN;
    end if;
    
    IF p_fecha_str IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: La fecha es un parametro obligatorio.');
        RETURN;
    end if;
    
    BEGIN
        --Convertir la cadena de fecha a fecha
        v_fecha := TO_DATE(p_fecha_str, 'DD/MM/YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Error: La fecha no tiene el formato correcto.');
            RETURN;
    end;
    
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

    IF p_id_cliente = 0 OR p_id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El id del cliente no puede ser nulo');
        RETURN;
    end if;
    
    IF LENGTH(p_detalle) > 40 THEN
        RAISE_APPLICATION_ERROR(-20001,'El detalle excede la cantidad maxima de caracteres, la cual es 40');
        RETURN;
    end if;
    
    SELECT COUNT(*) INTO v_id_ant
    FROM COMPRA
    WHERE ID_COMPRA = p_id_compra;
    
    IF v_id_ant > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id de la compra ya existe en la base de datos');
        RETURN;
    end if;
    

    -- Verificar que exista el id
    SELECT COUNT(*) INTO v_id_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_id_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id_cliente no existe.');
        RETURN;
    end if;

    -- Verificar que exista el id_pro_ser
    SELECT COUNT(*) INTO v_id_pro_ser_exist
    FROM PRO_SER
    WHERE ID_PRO_SER = p_id_pro_ser;

    IF v_id_pro_ser_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id de producto o servicio no existe.');
        RETURN;
    end if;

    SELECT TIPO INTO v_tipo_pro_ser
    FROM PRO_SER
    WHERE ID_PRO_SER = p_id_pro_ser;

    --Si es un producto(2) no debe ser nulo
    IF v_tipo_pro_ser = 2 AND (v_importe IS NULL OR v_importe <= 0) THEN
        raise_application_error(-20001, 'El importe es obligatorio para un producto y debe ser mayor a 0.');
        RETURN;
    end if;

    IF v_tipo_pro_ser = 1 AND v_importe IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El importe debe ser nulo para un servicio.');
        RETURN;
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
    
    IF p_no_cuenta = 0 or p_no_cuenta IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El parametro NO. Cuenta no puede ser nulo.');
        RETURN;
    end if;
    
    IF LENGTH(TO_CHAR(p_no_cuenta)) != 10 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El numero de cuenta no tiene un formato valido, debe contar con 10 digitos');
        RETURN;
    end if;

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
    IF p_id_cliente = 0 or p_id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id del cliente no puede ser null');
        RETURN;
    end if;

    SELECT COUNT(*)
    INTO v_cliente_exist
    FROM CLIENTE
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_cliente_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'No se encontro el cliente con el ID especificado');
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

create PROCEDURE consultarMovsCliente(
    p_id_cliente IN NUMBER
) AS
    v_json_response CLOB;
    v_cliente_exist NUMBER;
BEGIN
    IF p_id_cliente = 0 OR p_id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El parametro cliente no puede ser nulo.');
        RETURN;
    end if;
    
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

create PROCEDURE consultarTipoCuentas(
    p_id_tcuenta IN NUMBER
) AS
    v_tipo_cuenta NUMBER;
    v_nombre_cuenta VARCHAR2(40);
    v_cantidad_clientes NUMBER;
    v_tipo_exist NUMBER;
BEGIN
    
    IF p_id_tcuenta = 0 OR p_id_tcuenta IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El parametro tipo cuenta no puede ser nulo');
        RETURN;
    end if;
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

create PROCEDURE consultarMovsGenFech(
    p_fecha_inicio IN VARCHAR2,
    p_fecha_fin IN VARCHAR2
) AS
    v_json_response CLOB;
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
BEGIN
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
        WHERE trans.FECHA BETWEEN TO_DATE(p_fecha_inicio, 'DD/MM/YYYY') AND TO_DATE(p_fecha_fin, 'DD/MM/YYYY')
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

    IF v_json_response = '[' || CHR(10) THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron registros');
        RETURN;
    end if;
    -- Eliminar la última coma y agregar corchetes finales
    v_json_response := RTRIM(v_json_response, ',' || CHR(10)) || CHR(10) || ']';

    DBMS_OUTPUT.PUT_LINE(v_json_response);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al consultar los movimientos: ' || SQLERRM);
        ROLLBACK;
end;
/

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
    IF p_id_cliente = 0 OR p_id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El parametro cliente no puede ser nulo');
        RETURN;
    end if;
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

create PROCEDURE consultarDesasignacion AS
    v_json_response CLOB;
BEGIN
    v_json_response := '[' || CHR(10);

    -- Consultar los productos y servicios
    FOR prod_serv IN (
        SELECT ID_PRO_SER,
               DESCRIPCION,
               TIPO,
               CASE
                   WHEN TIPO = 2 THEN 'Producto'
                   WHEN TIPO = 1 THEN 'Servicio'
               END AS NOMBRE,
               COSTO
        FROM PRO_SER
    ) LOOP
        v_json_response := v_json_response || '{' || CHR(10)
                        || '"ID_PRO_SER": ' || prod_serv.ID_PRO_SER || ',' || CHR(10)
                        || '"Nombre": "' || prod_serv.DESCRIPCION || '",' || CHR(10)
                        || '"Tipo": "' || prod_serv.TIPO || '",' || CHR(10)
                        || '"Descripcion": "' || prod_serv.NOMBRE || '",' || chr(10)
                        || '"Costo": ' || prod_serv.COSTO || CHR(10)
                        || '},' || CHR(10);
    END LOOP;

    -- Eliminar la última coma y agregar corchetes finales
    v_json_response := RTRIM(v_json_response, ',' || CHR(10)) || CHR(10) || ']';

    DBMS_OUTPUT.PUT_LINE(v_json_response);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al consultar la información de los servicios: ' || SQLERRM);
        ROLLBACK;
END;
/

