// Importaciones
const oracledb = require('oracledb');
const { dbConfig } = require('../config');

// Funcion para eliminar las tablas
async function eliminarTablas(){
    try{
        // Realizar la conexión a la base de datos
        const connection = await oracledb.getConnection(dbConfig);

        // Realizar la consulta SQL para eliminar las tablas
        const query = `
            BEGIN
                EXECUTE IMMEDIATE 'DROP table ORDEN';
                EXECUTE IMMEDIATE 'DROP table DETALLE_ORDEN';
                EXECUTE IMMEDIATE 'DROP table PRODUCTO';
                EXECUTE IMMEDIATE 'DROP table VENDEDOR';
                EXECUTE IMMEDIATE 'DROP table CLIENTE';
                EXECUTE IMMEDIATE 'DROP table CATEGORIA';
                EXECUTE IMMEDIATE 'DROP table PAIS';
            END;
        `;
        await connection.execute(query);

        // Cerrar la conexión
        await connection.close();

        return {success: true, message: 'Tablas eliminadas correctamente'};
    } catch (error){
        console.error('Error eliminando las tablas', error);
        return {success: false, message: 'Error eliminando las tablas'};
    }
}

// Exportar la función
module.exports = eliminarTablas;