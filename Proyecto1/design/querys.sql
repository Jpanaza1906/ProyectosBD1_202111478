--CONSULTA 1:
SELECT
  *
FROM
  (
    SELECT
      C.ID_CLIENTE,
      C.NOMBRE AS nombre_cliente,
      C.APELLIDO AS apellido_cliente,
      pa.NOMBRE AS nombre_pais,
      SUM(p.PRECIO * do.CANTIDAD) AS monto_total,
      COUNT(o.ID_CLIENTE) AS numero_compras
    FROM
      cliente C
      JOIN orden o ON C.ID_CLIENTE = o.ID_CLIENTE
      JOIN DETALLE_ORDEN do ON o.ID_ORDEN = do.ID_ORDEN
      JOIN producto p ON do.ID_PRODUCTO = p.ID_PRODUCTO
      JOIN pais pa ON C.ID_PAIS = pa.ID_PAIS
    GROUP
      BY C.ID_CLIENTE,
      C.NOMBRE,
      C.APELLIDO,
      pa.NOMBRE
    ORDER
      BY COUNT(o.ID_CLIENTE) DESC
  )
WHERE
  ROWNUM <= 1 
  
--CONSULTA 2:
SELECT
  *
FROM
  (
    SELECT
      ID_PRODUCTO,
      nombre_producto,
      categoria,
      cantidad_total,
      monto_total,
      rm_mas,
      rm_menor
    FROM
      (
        SELECT
          p.ID_PRODUCTO,
          p.NOMBRE AS nombre_producto,
          C.NOMBRE AS categoria,
          SUM(o.cantidad) AS cantidad_total,
          SUM(o.cantidad * p.precio) AS monto_total,
          ROW_NUMBER() OVER (
            ORDER
              BY SUM(o.CANTIDAD) DESC
          ) AS rm_mas,
          ROW_NUMBER() OVER (
            ORDER
              BY SUM(o.CANTIDAD) ASC
          ) AS rm_menor
        FROM
          PRODUCTO p
          JOIN CATEGORIA C ON p.ID_CATEGORIA = C.ID_CATEGORIA
          JOIN DETALLE_ORDEN o ON p.ID_PRODUCTO = o.ID_PRODUCTO
        GROUP
          BY p.ID_PRODUCTO,
          p.NOMBRE,
          C.NOMBRE
      ) inner_query
  )
WHERE
  rm_mas = 1
  OR rm_menor = 1 
  
--CONSULTA 3:

SELECT
  ID_VENDEDOR,
  nombre_vendedor,
  monto_total
FROM
  (
    SELECT
      o.ID_VENDEDOR,
      v.NOMBRE AS nombre_vendedor,
      SUM(o.CANTIDAD * p.PRECIO) AS monto_total,
      ROW_NUMBER() OVER (
        ORDER
          BY SUM(o.CANTIDAD * p.PRECIO) DESC
      ) AS rm_mas
    FROM
      DETALLE_ORDEN o
      JOIN VENDEDOR v ON o.ID_VENDEDOR = v.ID_VENDEDOR
      JOIN PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
    GROUP
      BY o.ID_VENDEDOR,
      v.NOMBRE
  ) inner_query
WHERE
  rm_mas = 1

--CONSULTA 4:
SELECT
  nombre_pais,
  monto_total
FROM
  (
    SELECT
      pa.NOMBRE AS nombre_pais,
      SUM(o.CANTIDAD * p.PRECIO) AS monto_total,
      ROW_NUMBER() OVER (
        ORDER
          BY SUM(o.CANTIDAD * p.PRECIO) DESC
      ) AS rn_mas,
      ROW_NUMBER() OVER (
        ORDER
          BY SUM(o.CANTIDAD * p.PRECIO) ASC
      ) AS rn_menor
    FROM
      PAIS pa
      JOIN VENDEDOR v ON pa.ID_PAIS = v.ID_PAIS
      JOIN DETALLE_ORDEN o ON v.ID_VENDEDOR = o.ID_VENDEDOR
      JOIN PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
    GROUP
      BY pa.NOMBRE
  )
WHERE
  rn_mas = 1
  OR rn_menor = 1

--CONSULTA 5:
SELECT
  ID_PAIS,
  nombre_pais,
  monto_total
FROM
  (
    SELECT
      pa.ID_PAIS,
      pa.NOMBRE AS nombre_pais,
      SUM(o.CANTIDAD * p.PRECIO) AS monto_total,
      ROW_NUMBER() OVER (
        ORDER
          BY SUM(o.CANTIDAD * p.PRECIO) ASC
      ) AS rn
    FROM
      PAIS pa
      JOIN CLIENTE cl ON pa.ID_PAIS = cl.ID_PAIS
      JOIN ORDEN ord ON cl.ID_CLIENTE = ord.ID_CLIENTE
      JOIN DETALLE_ORDEN o ON ord.ID_ORDEN = o.ID_ORDEN
      JOIN PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
    GROUP
      BY pa.ID_PAIS,
      pa.NOMBRE
    ORDER
      BY monto_total DESC
  )
WHERE
  ROWNUM <= 5
ORDER
  BY monto_total ASC

--CONSULTA 6:
SELECT
  nombre_categoria,
  total_unidades,
  rn_mas,
  rn_menor
FROM
  (
    SELECT
      C.NOMBRE AS nombre_categoria,
      SUM(o.CANTIDAD) AS total_unidades,
      ROW_NUMBER() OVER (
        ORDER
          BY SUM(o.CANTIDAD) DESC
      ) AS rn_mas,
      ROW_NUMBER() OVER (
        ORDER
          BY SUM(o.CANTIDAD) ASC
      ) AS rn_menor
    FROM
      DETALLE_ORDEN o
      JOIN PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
      JOIN CATEGORIA C ON p.ID_CATEGORIA = C.ID_CATEGORIA
    GROUP
      BY C.NOMBRE
    ORDER
      BY total_unidades DESC
  )
WHERE
  rn_mas = 1
  OR rn_menor = 1

--CONSULTA 7:
SELECT
  nombre_pais,
  nombre_categoria,
  total_unidades
FROM
  (
    SELECT
      pa.NOMBRE AS nombre_pais,
      C.NOMBRE AS nombre_categoria,
      SUM(o.CANTIDAD) AS total_unidades,
      ROW_NUMBER() OVER (
        PARTITION BY pa.NOMBRE
        ORDER
          BY SUM(o.CANTIDAD) DESC
      ) AS rn
    FROM
      DETALLE_ORDEN o
      JOIN ORDEN ord ON o.ID_ORDEN = ord.ID_ORDEN
      JOIN CLIENTE cl ON ord.ID_CLIENTE = cl.ID_CLIENTE
      JOIN PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
      JOIN PAIS pa ON cl.ID_PAIS = pa.ID_PAIS
      JOIN CATEGORIA C ON p.ID_CATEGORIA = C.ID_CATEGORIA
    GROUP
      BY pa.NOMBRE,
      C.NOMBRE
  )
WHERE
  rn = 1
ORDER
  BY total_unidades DESC

--CONSULTA 8:
SELECT
  EXTRACT(
    MONTH
    FROM
      ord.FECHA_ORDEN
  ) AS numero_mes,
  SUM(p.PRECIO * o.CANTIDAD) AS monto_total
FROM
  DETALLE_ORDEN o
  JOIN ORDEN ord ON o.ID_ORDEN = ord.ID_ORDEN
  JOIN VENDEDOR v ON o.ID_VENDEDOR = v.ID_VENDEDOR
  JOIN PAIS pa ON v.ID_PAIS = pa.ID_PAIS
  JOIN PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
WHERE
  pa.NOMBRE = 'Inglaterra'
GROUP
  BY EXTRACT(
    MONTH
    FROM
      ord.FECHA_ORDEN
  )
ORDER
  BY numero_mes

--CONSULTA 9:
SELECT
  numero_mes,
  monto_total,
  rm_mas,
  rm_menos
FROM
  (
    SELECT
      EXTRACT(
        MONTH
        FROM
          ord.FECHA_ORDEN
      ) AS numero_mes,
      SUM(p.PRECIO * o.CANTIDAD) AS monto_total,
      ROW_NUMBER() OVER (
        ORDER
          BY SUM(p.PRECIO * o.CANTIDAD) DESC
      ) AS rm_mas,
      ROW_NUMBER() OVER (
        ORDER
          BY SUM(p.PRECIO * o.CANTIDAD) ASC
      ) AS rm_menos
    FROM
      DETALLE_ORDEN o
      JOIN ORDEN ord ON o.ID_ORDEN = ord.ID_ORDEN
      JOIN VENDEDOR v ON o.ID_VENDEDOR = v.ID_VENDEDOR
      JOIN PAIS pa ON v.ID_PAIS = pa.ID_PAIS
      JOIN PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
    GROUP
      BY EXTRACT(
        MONTH
        FROM
          ord.FECHA_ORDEN
      )
    ORDER
      BY numero_mes
  )
WHERE
  rm_mas = 1
  OR rm_menos = 1

--CONSULTA 10:
SELECT
  o.ID_PRODUCTO,
  p.NOMBRE AS nombre_producto,
  SUM(o.CANTIDAD * p.PRECIO) AS monto_total
FROM
  DETALLE_ORDEN o
  JOIN PRODUCTO p ON o.ID_PRODUCTO = p.ID_PRODUCTO
  JOIN CATEGORIA C ON p.ID_CATEGORIA = C.ID_CATEGORIA
WHERE
  C.ID_CATEGORIA = 15
GROUP
  BY o.ID_PRODUCTO,
  p.NOMBRE
ORDER
  BY monto_total DESC