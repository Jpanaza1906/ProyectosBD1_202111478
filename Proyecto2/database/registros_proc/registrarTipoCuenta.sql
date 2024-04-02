create PROCEDURE registrarTipoCuenta(
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2
) AS
BEGIN
    IF p_nombre IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El nombre es un campo obligatorio.');
        RETURN;
    end if;

    IF p_descripcion IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'La descripcion es un campo obligatorio.');
        RETURN;
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

