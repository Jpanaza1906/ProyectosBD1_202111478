
CREATE TABLE categoria (
    id_categoria INTEGER NOT NULL,
    nombre       VARCHAR2(25 CHAR) NOT NULL
);

ALTER TABLE categoria ADD CONSTRAINT categoria_pk PRIMARY KEY ( id_categoria );

CREATE TABLE cliente (
    id_cliente INTEGER NOT NULL,
    nombre     VARCHAR2(25 CHAR) NOT NULL,
    apellido   VARCHAR2(25 CHAR) NOT NULL,
    direccion  VARCHAR2(50 CHAR) NOT NULL,
    telefono   VARCHAR2(20 CHAR) NOT NULL,
    tarjeta    INTEGER NOT NULL,
    edad       INTEGER NOT NULL,
    salario    INTEGER NOT NULL,
    genero     VARCHAR2(1 CHAR) NOT NULL,
    id_pais    INTEGER NOT NULL
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cliente );

CREATE TABLE detalle_orden (
    id_orden    INTEGER NOT NULL,
    linea_orden INTEGER NOT NULL,
    cantidad    INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    id_vendedor INTEGER NOT NULL
);

ALTER TABLE detalle_orden ADD CONSTRAINT detalle_orden_pk PRIMARY KEY ( id_orden,
                                                                        linea_orden );

CREATE TABLE orden (
    fecha_orden DATE NOT NULL,
    id_cliente  INTEGER NOT NULL,
    id_orden    INTEGER NOT NULL,
    linea_orden INTEGER NOT NULL
);

ALTER TABLE orden ADD CONSTRAINT orden_pk PRIMARY KEY ( id_orden );

CREATE TABLE pais (
    id_pais INTEGER NOT NULL,
    nombre  VARCHAR2(25 CHAR) NOT NULL
);

ALTER TABLE pais ADD CONSTRAINT pais_pk PRIMARY KEY ( id_pais );

CREATE TABLE producto (
    id_producto  INTEGER NOT NULL,
    nombre       VARCHAR2(25 CHAR) NOT NULL,
    precio       NUMBER(10,2) NOT NULL,
    id_categoria INTEGER NOT NULL
);

ALTER TABLE producto ADD CONSTRAINT producto_pk PRIMARY KEY ( id_producto );

CREATE TABLE vendedor (
    id_vendedor INTEGER NOT NULL,
    nombre      VARCHAR2(25 CHAR) NOT NULL,
    id_pais     INTEGER NOT NULL
);

ALTER TABLE vendedor ADD CONSTRAINT vendedor_pk PRIMARY KEY ( id_vendedor );

ALTER TABLE cliente
    ADD CONSTRAINT cliente_pais_fk FOREIGN KEY ( id_pais )
        REFERENCES pais ( id_pais );

ALTER TABLE detalle_orden
    ADD CONSTRAINT detalle_orden_producto_fk FOREIGN KEY ( id_producto )
        REFERENCES producto ( id_producto );

ALTER TABLE detalle_orden
    ADD CONSTRAINT detalle_orden_vendedor_fk FOREIGN KEY ( id_vendedor )
        REFERENCES vendedor ( id_vendedor );

ALTER TABLE orden
    ADD CONSTRAINT orden_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE orden
    ADD CONSTRAINT orden_detalle_orden_fk FOREIGN KEY ( id_orden,
                                                        linea_orden )
        REFERENCES detalle_orden ( id_orden,
                                   linea_orden );

ALTER TABLE producto
    ADD CONSTRAINT producto_categoria_fk FOREIGN KEY ( id_categoria )
        REFERENCES categoria ( id_categoria );

ALTER TABLE vendedor
    ADD CONSTRAINT vendedor_pais_fk FOREIGN KEY ( id_pais )
        REFERENCES pais ( id_pais );
