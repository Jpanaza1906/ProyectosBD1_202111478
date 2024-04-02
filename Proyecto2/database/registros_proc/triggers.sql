-- Trigger para validar el autoincrementable en los ids

CREATE OR REPLACE TRIGGER telefono_id_trigger
BEFORE INSERT OR UPDATE ON TELEFONO
FOR EACH ROW
BEGIN
    SELECT NVL(MAX(ID_TELEFONO), 0) + 1 INTO :NEW.ID_TELEFONO FROM TELEFONO; -- Obtener el último ID y sumar 1
END;
/

-- Trigger para validar solo letras

CREATE OR REPLACE TRIGGER tcliente_vdescrip
BEFORE INSERT OR UPDATE ON TIPO_CLIENTE
FOR EACH ROW
DECLARE
    v_patron VARCHAR2(40) := '^[[:alpha:] .,]+$'; -- Expresión regular para letras y espacios
BEGIN
    IF NOT REGEXP_LIKE(:NEW.DESCRIPCION, v_patron) THEN
        RAISE_APPLICATION_ERROR(-20001, 'La descripcion puede tener unicamente letras, espacios, comas y puntos.');
    END IF;
END;
/

-- Trigger para validar que el usuario no exista

CREATE OR REPLACE TRIGGER cliente_vusuario
BEFORE INSERT OR UPDATE ON CLIENTE
FOR EACH ROW
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

-- Trigger para validar que la contrasena se encripte al insertar
CREATE OR REPLACE TRIGGER cliente_vcontrasena
BEFORE INSERT OR UPDATE ON CLIENTE
FOR EACH ROW
DECLARE
    v_hash varchar2(200);
BEGIN
    -- se genera el hash de la contrasena utilizando sha-256
    v_hash := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(:NEW.CONTRASENA),5);

    -- almacenar el hash en el campo de contrasena
    :NEW.CONTRASENA := v_hash;
end;
/

-- Trigger para validar que el correo lleve un formato correcto

CREATE OR REPLACE TRIGGER correo_vdireccion
BEFORE INSERT OR UPDATE ON CORREO
FOR EACH ROW
DECLARE
    v_patron VARCHAR2(100) := '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
BEGIN
    IF NOT REGEXP_LIKE(:NEW.DIRECCION, v_patron) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El correo electrónico no tiene un formato válido.');
    END IF;
END;
/

-- Trigger para validar que el numero de telefono obvie el codigo de area

CREATE OR REPLACE TRIGGER telefono_vnumero
BEFORE INSERT OR UPDATE ON TELEFONO
FOR EACH ROW
BEGIN
    IF LENGTH(:NEW.NUMERO) < 8 THEN
        RAISE_APPLICATION_ERROR(-20001,'El numero de telefono debe tener al menos 8 digitos.');
    ELSIF LENGTH(:NEW.NUMERO) > 8 THEN
        :NEW.NUMERO := SUBSTR(:NEW.NUMERO, -8);
    end if;
end;
/
-- Trigger para validar que no se pueda modificar el monto

CREATE OR REPLACE TRIGGER cuenta_vmonto
BEFORE UPDATE ON CUENTA
FOR EACH ROW
BEGIN
    IF :OLD.MONTO_APERTURA != :NEW.MONTO_APERTURA THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede modificar el monto de apertura.');
    end if;
end;
/
-- Trigger para validar que el saldo sea mayor a 0

CREATE OR REPLACE TRIGGER cuenta_vsaldo
BEFORE INSERT OR UPDATE ON CUENTA
FOR EACH ROW
BEGIN
    IF :NEW.SALDO <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El saldo debe ser mayor o igual a 0');
    end if;
    IF :NEW.MONTO_APERTURA <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El monto de apertura debe ser mayor o igual a 0');
    end if;
end;
/

-- Trigger para validar que el tipo sea o 1 o 2

CREATE OR REPLACE TRIGGER pro_ser_vtipo
BEFORE INSERT OR UPDATE ON PRO_SER
FOR EACH ROW
BEGIN
    IF :NEW.TIPO NOT IN (1,2) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El tipo deber ser 1 para servicio y 2 para producto.');
    end if;
end;
/

-- Trigger para validar el costo segun producto o servicio

CREATE OR REPLACE TRIGGER pro_ser_vcosto
BEFORE INSERT OR UPDATE ON PRO_SER
FOR EACH ROW
BEGIN
    IF :NEW.TIPO = 1 AND (:NEW.COSTO IS NULL OR :NEW.COSTO < 0) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El costo es obligatorio y debe ser mayor a 0 para un servicio.');
    end if;

    IF :NEW.TIPO = 2 AND :NEW.COSTO IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El costo debe ser nulo para un producto.');
    end if;
end;

-- BITACORA CREACION

CREATE TABLE Bitacora(
    fecha timestamp default current_timestamp,
    descripcion varchar2(255),
    tipo varchar2(10)
);

--TRIGGERS PARA LAS TABLAS

CREATE OR REPLACE TRIGGER transaccion_insert
AFTER INSERT ON TRANSACCION
FOR EACH ROW
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se insertó un nuevo registro en la tabla TRANSACCION.','INSERT');
end;

CREATE OR REPLACE TRIGGER transaccion_update
AFTER UPDATE ON TRANSACCION
FOR EACH ROW
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se actualizó un nuevo registro en la tabla TRANSACCION.','UPDATE');
end;

CREATE OR REPLACE TRIGGER transaccion_delete
AFTER DELETE ON TRANSACCION
FOR EACH ROW
BEGIN
    INSERT INTO BITACORA (descripcion, tipo)
    VALUES ('Se eliminó un nuevo registro en la tabla TRANSACCION.','DELETE');
end;