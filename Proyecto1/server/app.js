/**
 * Creado por: Jose David Panaza Batres
 * Carnet: 202111478
 * Fecha: 26/02/2024
 * Descripcion: API en Node.js para el proyecto 1 de sistemas de bases de datos.
 * Curso: Sistemas de Bases de Datos 1
 * Seccion: B
 */

// Importar modulos necesarios
const express = require('express');
const morgan = require('morgan');

// Importar las rutas
const conexionRouter = require('./routes/conexion');
const procesosdb = require('./routes/procesosdb');

//--------------------------------------------------------------------------------

// Crear la aplicacion de express
const app = express();

// configurar morgan
app.use(morgan('dev'));

// Usar las rutas de conexion
app.use('/', conexionRouter);
app.use('/',procesosdb);

// Iniciar el servidor de express
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor iniciado en el puerto ${PORT}`);
});