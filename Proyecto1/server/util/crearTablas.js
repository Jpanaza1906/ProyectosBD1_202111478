const oracledb = require('oracledb');
const { dbConfig } = require('../config');

//funcion para crear tablas

async function crearTablas() {
    try {
        const connection = await oracledb.getConnection(dbConfig);

        // ejecutar el codigo sql para crear las tablas
        const sql = `
        BEGIN
            EXECUTE IMMEDIATE '
            CREATE TABLE categoria (
                id_categoria INTEGER NOT NULL,
                nombre       VARCHAR2(25 CHAR) NOT NULL
            )';

            EXECUTE IMMEDIATE '
            ALTER TABLE categoria ADD CONSTRAINT categoria_pk PRIMARY KEY ( id_categoria )';

            EXECUTE IMMEDIATE '
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
            )';

            EXECUTE IMMEDIATE '
            ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cliente )';

            EXECUTE IMMEDIATE '
            CREATE TABLE detalle_orden (
                id_orden    INTEGER NOT NULL,
                linea_orden INTEGER NOT NULL,
                id_vendedor INTEGER NOT NULL,
                id_producto INTEGER NOT NULL,
                cantidad    INTEGER NOT NULL
            )';

            EXECUTE IMMEDIATE '
            ALTER TABLE detalle_orden ADD CONSTRAINT detalle_orden_pk PRIMARY KEY ( id_orden,
                                                                                    linea_orden )';

            EXECUTE IMMEDIATE '
            CREATE TABLE orden (
                id_orden    INTEGER NOT NULL,
                fecha_orden DATE NOT NULL,
                id_cliente  INTEGER NOT NULL,
                linea_orden INTEGER NOT NULL
            )';

            EXECUTE IMMEDIATE '
            ALTER TABLE orden ADD CONSTRAINT orden_pk PRIMARY KEY ( id_orden )';

            EXECUTE IMMEDIATE '
            CREATE TABLE pais (
                id_pais INTEGER NOT NULL,
                nombre  VARCHAR2(25 CHAR) NOT NULL
            )';

            EXECUTE IMMEDIATE '
            ALTER TABLE pais ADD CONSTRAINT pais_pk PRIMARY KEY ( id_pais )';

            EXECUTE IMMEDIATE '
            CREATE TABLE producto (
                id_producto  INTEGER NOT NULL,
                nombre       VARCHAR2(25 CHAR) NOT NULL,
                precio       NUMBER(10,2) NOT NULL,
                id_categoria INTEGER NOT NULL
            )';

            EXECUTE IMMEDIATE '
            ALTER TABLE producto ADD CONSTRAINT producto_pk PRIMARY KEY ( id_producto )';

            EXECUTE IMMEDIATE '
            CREATE TABLE vendedor (
                id_vendedor INTEGER NOT NULL,
                nombre      VARCHAR2(25 CHAR) NOT NULL,
                id_pais     INTEGER NOT NULL
            )';

            EXECUTE IMMEDIATE '
            ALTER TABLE vendedor ADD CONSTRAINT vendedor_pk PRIMARY KEY ( id_vendedor )';

            EXECUTE IMMEDIATE '
            ALTER TABLE cliente
                ADD CONSTRAINT cliente_pais_fk FOREIGN KEY ( id_pais )
                    REFERENCES pais ( id_pais )';

            EXECUTE IMMEDIATE '
            ALTER TABLE detalle_orden
                ADD CONSTRAINT detalle_orden_producto_fk FOREIGN KEY ( id_producto )
                    REFERENCES producto ( id_producto )';

            EXECUTE IMMEDIATE '
            ALTER TABLE detalle_orden
                ADD CONSTRAINT detalle_orden_vendedor_fk FOREIGN KEY ( id_vendedor )
                    REFERENCES vendedor ( id_vendedor )';

            EXECUTE IMMEDIATE '
            ALTER TABLE orden
                ADD CONSTRAINT orden_cliente_fk FOREIGN KEY ( id_cliente )
                    REFERENCES cliente ( id_cliente )';

            EXECUTE IMMEDIATE '
            ALTER TABLE orden
                ADD CONSTRAINT orden_detalle_orden_fk FOREIGN KEY ( id_orden,
                                                                    linea_orden )
                    REFERENCES detalle_orden ( id_orden,
                                            linea_orden )';

            EXECUTE IMMEDIATE '
            ALTER TABLE producto
                ADD CONSTRAINT producto_categoria_fk FOREIGN KEY ( id_categoria )
                    REFERENCES categoria ( id_categoria )';

            EXECUTE IMMEDIATE '
            ALTER TABLE vendedor
                ADD CONSTRAINT vendedor_pais_fk FOREIGN KEY ( id_pais )
                    REFERENCES pais ( id_pais )';
        END;
        `;

        await connection.execute(sql);

        //cerrar la conexion
        await connection.close();

        return { success: true, message: 'Tablas creadas correctamente' };

    } catch (error) {
        console.error('Error creando las tablas', error);
        return { success: false, message: 'Error creando las tablas' };
    }
}

//exportar la funcion
module.exports = crearTablas;