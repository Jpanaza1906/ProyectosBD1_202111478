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

