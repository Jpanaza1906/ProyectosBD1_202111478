const express = require('express');
const oracledb = require('oracledb');
const { dbConfig } = require('../config');
const router = express.Router();

// Endoint para probar la conexión a la base de datos
router.get('/conexion', async (req, res) => {
    try{
        //Realizar la conexión a la base de datos
        const connection = await oracledb.getConnection(dbConfig);

        //Realizar una consulta de prueba
        const result = await connection.execute(
            `SELECT 'Conexion exitosa' AS message FROM dual`
        );
        
        //Cerrar la conexión
        await connection.close();

        //Enviar la respuesta
        res.status(200).json({conexion: result.rows[0][0]});

    } catch (error){
        console.error('Error en la conexión a la base de datos', error);
        res.status(500).json({error: 'Error en la conexión a la base de datos'});
    }
});

module.exports = router;