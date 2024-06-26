-- Generated by Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   at:        2024-03-29 10:35:59 CST
--   site:      Oracle Database 11g
--   type:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE cliente (
    id_cliente  INTEGER NOT NULL,
    nombre      VARCHAR2(40 CHAR) NOT NULL,
    apellido    VARCHAR2(40 CHAR) NOT NULL,
    usuario     VARCHAR2(40 CHAR) NOT NULL,
    contrasena  VARCHAR2(200 CHAR) NOT NULL,
    fecha       DATE NOT NULL,
    id_tcliente INTEGER NOT NULL
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cliente );

CREATE TABLE compra (
    id_compra  INTEGER NOT NULL,
    fecha      DATE NOT NULL,
    importe    NUMBER(12, 2),
    detalle    VARCHAR2(40 CHAR),
    id_pro_ser INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL
);

ALTER TABLE compra ADD CONSTRAINT compra_pk PRIMARY KEY ( id_compra );

CREATE TABLE correo (
    id_correo  INTEGER NOT NULL,
    direccion  VARCHAR2(40 CHAR) NOT NULL,
    id_cliente INTEGER NOT NULL
);

ALTER TABLE correo ADD CONSTRAINT correo_pk PRIMARY KEY ( id_correo );

CREATE TABLE cuenta (
    id_cuenta      INTEGER NOT NULL,
    monto_apertura NUMBER(12, 2) NOT NULL,
    saldo          NUMBER(12, 2) NOT NULL,
    descripcion    VARCHAR2(50 CHAR) NOT NULL,
    fecha_apertura DATE NOT NULL,
    detalle        VARCHAR2(100 CHAR),
    id_tcuenta     INTEGER NOT NULL,
    id_cliente     INTEGER NOT NULL
);

ALTER TABLE cuenta ADD CONSTRAINT cuenta_pk PRIMARY KEY ( id_cuenta );

CREATE TABLE debito (
    id_debito  INTEGER NOT NULL,
    fecha      DATE NOT NULL,
    monto      NUMBER(12, 2) NOT NULL,
    detalle    VARCHAR2(40 CHAR),
    id_cliente INTEGER NOT NULL
);

ALTER TABLE debito ADD CONSTRAINT debito_pk PRIMARY KEY ( id_debito );

CREATE TABLE deposito (
    id_deposito INTEGER NOT NULL,
    fecha       DATE NOT NULL,
    monto       NUMBER(12, 2) NOT NULL,
    detalle     VARCHAR2(40 CHAR),
    id_cliente  INTEGER NOT NULL
);

ALTER TABLE deposito ADD CONSTRAINT deposito_pk PRIMARY KEY ( id_deposito );

CREATE TABLE pro_ser (
    id_pro_ser  INTEGER NOT NULL,
    tipo        INTEGER NOT NULL,
    costo       NUMBER(12, 2),
    descripcion VARCHAR2(100 CHAR) NOT NULL
);

ALTER TABLE pro_ser ADD CONSTRAINT pro_ser_pk PRIMARY KEY ( id_pro_ser );

CREATE TABLE telefono (
    id_telefono INTEGER NOT NULL,
    numero      VARCHAR2(12 CHAR) NOT NULL,
    id_cliente  INTEGER NOT NULL
);

ALTER TABLE telefono ADD CONSTRAINT telefono_pk PRIMARY KEY ( id_telefono );

CREATE TABLE tipo_cliente (
    id_tcliente INTEGER NOT NULL,
    nombre      VARCHAR2(20 CHAR) NOT NULL,
    descripcion VARCHAR2(40 CHAR) NOT NULL
);

ALTER TABLE tipo_cliente ADD CONSTRAINT tipo_cliente_pk PRIMARY KEY ( id_tcliente );

CREATE TABLE tipo_cuenta (
    id_tcuenta  INTEGER NOT NULL,
    nombre      VARCHAR2(20 CHAR) NOT NULL,
    descripcion VARCHAR2(100 CHAR) NOT NULL
);

ALTER TABLE tipo_cuenta ADD CONSTRAINT tipo_cuenta_pk PRIMARY KEY ( id_tcuenta );

CREATE TABLE tipo_trans (
    id_ttrans   INTEGER NOT NULL,
    nombre      VARCHAR2(20 CHAR) NOT NULL,
    descripcion VARCHAR2(40 CHAR) NOT NULL
);

ALTER TABLE tipo_trans ADD CONSTRAINT tipo_trans_pk PRIMARY KEY ( id_ttrans );

CREATE TABLE transaccion (
    id_transaccion INTEGER NOT NULL,
    fecha          DATE NOT NULL,
    detalle        VARCHAR2(40 CHAR),
    id_ttrans      INTEGER NOT NULL,
    id_deposito    INTEGER NOT NULL,
    id_debito      INTEGER NOT NULL,
    id_compra      INTEGER NOT NULL,
    id_cuenta      INTEGER NOT NULL
);

CREATE UNIQUE INDEX transaccion__idx ON
    transaccion (
        id_compra
    ASC );

CREATE UNIQUE INDEX transaccion__idxv1 ON
    transaccion (
        id_debito
    ASC );

CREATE UNIQUE INDEX transaccion__idxv2 ON
    transaccion (
        id_deposito
    ASC );

ALTER TABLE transaccion ADD CONSTRAINT transaccion_pk PRIMARY KEY ( id_transaccion );

ALTER TABLE cliente
    ADD CONSTRAINT cliente_tipo_cliente_fk FOREIGN KEY ( id_tcliente )
        REFERENCES tipo_cliente ( id_tcliente );

ALTER TABLE compra
    ADD CONSTRAINT compra_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE compra
    ADD CONSTRAINT compra_pro_ser_fk FOREIGN KEY ( id_pro_ser )
        REFERENCES pro_ser ( id_pro_ser );

ALTER TABLE correo
    ADD CONSTRAINT correo_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE cuenta
    ADD CONSTRAINT cuenta_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE cuenta
    ADD CONSTRAINT cuenta_tipo_cuenta_fk FOREIGN KEY ( id_tcuenta )
        REFERENCES tipo_cuenta ( id_tcuenta );

ALTER TABLE debito
    ADD CONSTRAINT debito_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE deposito
    ADD CONSTRAINT deposito_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE telefono
    ADD CONSTRAINT telefono_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_compra_fk FOREIGN KEY ( id_compra )
        REFERENCES compra ( id_compra );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_cuenta_fk FOREIGN KEY ( id_cuenta )
        REFERENCES cuenta ( id_cuenta );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_debito_fk FOREIGN KEY ( id_debito )
        REFERENCES debito ( id_debito );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_deposito_fk FOREIGN KEY ( id_deposito )
        REFERENCES deposito ( id_deposito );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_tipo_trans_fk FOREIGN KEY ( id_ttrans )
        REFERENCES tipo_trans ( id_ttrans );



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                            12
-- CREATE INDEX                             3
-- ALTER TABLE                             26
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
