--CONSULTA 1:

SELECT *
FROM (
    SELECT
        c.id_cliente,
        c.nombre AS nombre_cliente,
        c.apellido AS apellido_cliente,
        pa.nombre AS nombre_pais,
        SUM(p.precio * o.cantidad) AS monto_total,
        SUM(CASE WHEN o.linea_orden = 1 THEN 1 ELSE 0 END) AS numero_compras
    FROM
        cliente c
    JOIN
        orden o ON c.id_cliente = o.id_cliente
    JOIN
        producto p ON o.id_producto = p.id_producto
    JOIN
        pais pa ON c.ID_PAIS = pa.ID_PAIS
    GROUP BY
        c.id_cliente,
        c.nombre,
        c.apellido,
        pa.nombre
    ORDER BY
        SUM(CASE WHEN o.linea_orden = 1 THEN 1 ELSE 0 END) DESC
)
WHERE ROWNUM <= 1;

--CONSULTA 2:

    SELECT
        ID_PRODUCTO,
        nombre_producto,
        categoria,
        cantidad_total,
        monto_total
    FROM (
        SELECT p.ID_PRODUCTO,
               p.NOMBRE AS nombre_producto,
               c.NOMBRE AS categoria,
               SUM(o.cantidad) AS cantidad_total,
               SUM(o.cantidad * p.precio) AS monto_total,
               ROW_NUMBER() over (order by SUM(o.CANTIDAD) DESC) AS rm_mas,
               ROW_NUMBER() over ( order by SUM(o.CANTIDAD) ASC) AS rm_menor
        FROM PRODUCTO p
        JOIN CATEGORIA c ON p.ID_CATEGORIA = c.ID_CATEGORIA
        JOIN ORDEN o ON p.ID_PRODUCTO = o.ID_PRODUCTO
        GROUP BY p.ID_PRODUCTO,
                 p.NOMBRE,
                 c.NOMBRE
        ORDER BY cantidad_total DESC
    )
    WHERE rm_mas = 1 OR rm_menor = 1;

--CONSULTA 3:

SELECT *
FROM (SELECT o.ID_VENDEDOR,
             v.NOMBRE AS nombre_vendedor,
             SUM(o.CANTIDAD * p.PRECIO) AS monto_total
      FROM ORDEN o
               JOIN
           VENDEDOR v on o.ID_VENDEDOR = v.ID_VENDEDOR
               JOIN
           PRODUCTO p on o.ID_PRODUCTO = p.ID_PRODUCTO
      GROUP BY O.ID_VENDEDOR, v.NOMBRE
      ORDER BY monto_total DESC)
WHERE ROWNUM <= 1;

--CONSULTA 4:

    SELECT
          nombre_pais,
          monto_total
          FROM (SELECT pa.NOMBRE                  AS nombre_pais,
                       SUM(o.CANTIDAD * p.PRECIO) AS monto_total,
                       ROW_NUMBER() over (order by SUM(o.CANTIDAD * p.PRECIO) DESC) AS rn_mas,
                       ROW_NUMBER() over (order by SUM(o.CANTIDAD * p.PRECIO) ASC ) AS rn_menor
                FROM PAIS pa
                         JOIN
                     VENDEDOR v on pa.ID_PAIS = v.ID_PAIS
                         JOIN
                     ORDEN o on v.ID_VENDEDOR = o.ID_VENDEDOR
                         JOIN
                     PRODUCTO p on o.ID_PRODUCTO = p.ID_PRODUCTO
                GROUP BY pa.NOMBRE
                ORDER BY monto_total DESC)
          WHERE rn_mas = 1 or rn_menor = 1;

--CONSULTA 5:

SELECT *
FROM (
    SELECT
        pa.ID_PAIS,
        pa.NOMBRE AS nombre_pais,
        SUM(o.CANTIDAD * p.PRECIO) AS monto_total
    FROM PAIS pa
    JOIN
        CLIENTE cl on pa.ID_PAIS = cl.ID_PAIS
    JOIN
        ORDEN o on cl.ID_CLIENTE = o.ID_CLIENTE
    JOIN
        PRODUCTO p on o.ID_PRODUCTO = p.ID_PRODUCTO
    GROUP BY pa.ID_PAIS,pa.NOMBRE
    ORDER BY monto_total DESC
)
WHERE ROWNUM <= 5
ORDER BY monto_total ASC;

--CONSULTA 6:

SELECT
    nombre_categoria,
    total_unidades
      FROM (SELECT c.NOMBRE        AS nombre_categoria,
                   SUM(o.CANTIDAD) AS total_unidades,
                   ROW_NUMBER() over (order by SUM(o.CANTIDAD) DESC) AS rn_mas,
                   ROW_NUMBER() over (order by SUM(o.CANTIDAD) ASC ) AS rn_menor
            FROM ORDEN o
                     JOIN
                 PRODUCTO p on o.ID_PRODUCTO = p.ID_PRODUCTO
                     JOIN
                 CATEGORIA c on p.ID_CATEGORIA = c.ID_CATEGORIA
            GROUP BY c.NOMBRE
            ORDER BY total_unidades DESC)
      WHERE rn_mas = 1 or rn_menor = 1;

--CONSULTA 7:

SELECT nombre_pais, nombre_categoria, total_unidades
FROM (
    SELECT
        pa.NOMBRE AS nombre_pais,
        c.NOMBRE AS nombre_categoria,
        SUM(o.CANTIDAD) AS total_unidades,
        ROW_NUMBER() OVER (PARTITION BY pa.NOMBRE ORDER BY SUM(o.CANTIDAD) DESC) AS rn
    FROM
        ORDEN o
    JOIN
        CLIENTE cl ON o.ID_CLIENTE = cl.ID_CLIENTE
    JOIN
        PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
    JOIN
        PAIS pa ON cl.ID_PAIS = pa.ID_PAIS
    JOIN
        CATEGORIA c ON p.ID_CATEGORIA = c.ID_CATEGORIA
    GROUP BY
        pa.NOMBRE, c.NOMBRE
)
WHERE rn = 1
ORDER BY total_unidades DESC;

--CONSULTA 8:

SELECT
    EXTRACT(MONTH FROM o.FECHA_ORDEN) AS numero_mes,
    SUM(p.PRECIO * o.CANTIDAD) AS monto_total
FROM
    ORDEN o
JOIN
    VENDEDOR v ON o.ID_VENDEDOR = v.ID_VENDEDOR
JOIN
    PAIS pa ON v.ID_PAIS = pa.ID_PAIS
JOIN
    PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
WHERE
    pa.NOMBRE = 'Inglaterra'
GROUP BY
    EXTRACT(MONTH FROM o.fecha_orden)
ORDER BY
    numero_mes;

--CONSULTA 9:

SELECT
    numero_mes,
    monto_total
FROM(
SELECT
    EXTRACT(MONTH FROM o.FECHA_ORDEN) AS numero_mes,
    SUM(p.PRECIO * o.CANTIDAD) AS monto_total,
    ROW_NUMBER() over (ORDER BY SUM(p.PRECIO * o.CANTIDAD) DESC) AS rm_mas,
    ROW_NUMBER() over (ORDER BY SUM(p.PRECIO * o.CANTIDAD) ASC) AS rm_menos
FROM
    ORDEN o
JOIN
    VENDEDOR v ON o.ID_VENDEDOR = v.ID_VENDEDOR
JOIN
    PAIS pa ON v.ID_PAIS = pa.ID_PAIS
JOIN
    PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
GROUP BY
    EXTRACT(MONTH FROM o.fecha_orden)
ORDER BY
    numero_mes)
WHERE rm_mas = 1 OR rm_menos = 1;

--CONSULTA 10:

SELECT
    o.ID_PRODUCTO,
    p.NOMBRE AS nombre_producto,
    SUM(o.CANTIDAD * p.PRECIO) AS monto_total
FROM
    ORDEN o
JOIN
    PRODUCTO p on o.ID_PRODUCTO = p.ID_PRODUCTO
JOIN
    CATEGORIA c on p.ID_CATEGORIA = c.ID_CATEGORIA
WHERE
    c.ID_CATEGORIA = 15
GROUP BY
    o.ID_PRODUCTO, p.NOMBRE
ORDER BY
    monto_total DESC ;
