const oracledb = require('oracledb');
const { dbConfig } = require('../config');

// Funcion para eliminar las tablas

async function borrarTablas(){
    try{
        const connection = await oracledb.getConnection(dbConfig);

        //ejecutar el codigo sql para borrar los registros de las tablas
        const sql = `
        BEGIN
            EXECUTE IMMEDIATE 'DELETE FROM ORDEN';
            EXECUTE IMMEDIATE 'DELETE FROM PRODUCTO';
            EXECUTE IMMEDIATE 'DELETE FROM VENDEDOR';
            EXECUTE IMMEDIATE 'DELETE FROM CLIENTE';
            EXECUTE IMMEDIATE 'DELETE FROM CATEGORIA';
            EXECUTE IMMEDIATE 'DELETE FROM PAIS';
        END;
        `
        await connection.execute(sql);
        await connection.commit();

        //Cerrar la conexion
        await connection.close();

        return {success: true, message: 'Tablas borradas correctamente'};



    } catch (error){
        console.error('Error borrando las tablas', error);
        return {success: false, message: 'Error borrando las tablas'};
    }
}

// Exportar la funcion
module.exports = borrarTablas;