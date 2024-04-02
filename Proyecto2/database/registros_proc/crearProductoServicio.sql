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

