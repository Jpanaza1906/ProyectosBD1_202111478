// Importacion de los paquetes y modulos a utilizar
const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const eliminarTablas = require('../util/eliminarTablas');
const borrarTablas = require('../util/borrarTablas');
const crearTablas = require('../util/crearTablas');
const cargarTablas = require('../util/cargarTablas');

// =============================================================== ELIMINAR MODELO ===============================================================

router.get('/eliminarmodelo', async (req, res) => {
    try{
        // Llamar a la funcion para eliminar las tablas
        const resultado = await eliminarTablas();
        
        if (resultado.success){
            res.status(200).json({message: resultado.message});
        } else{
            res.status(500).json({error: resultado.message});
        }
    
    } catch (error){
        res.status(500).json({error: 'Error eliminando las tablas'});
    }
});

// =============================================================== CREAR MODELO ===============================================================

router.get('/crearmodelo', async (req, res) => {
    try{
        // Llamar a la funcion para crear las tablas
        const resultado = await crearTablas();
        if (resultado.success){
            res.status(200).json({message: resultado.message});
        } else{
            res.status(500).json({error: resultado.message});
        }
    
    } catch (error){
        console.error('Error creando las tablas', error);
        res.status(500).json({error: 'Error creando las tablas'});
    }
});

// =============================================================== BORRAR INFO DB ===============================================================

router.get('/borrarinfodb', async (req, res) => {
    try{
        // Llamar a la funcion para eliminar las tablas
        const resultado = await borrarTablas();
        
        if (resultado.success){
            res.status(200).json({message: resultado.message});
        } else{
            res.status(500).json({error: resultado.message});
        }
    
    } catch (error){
        res.status(500).json({error: 'Error eliminando las tablas'});
    }
});

// =============================================================== CARGAR MODELO ===============================================================

router.get('/cargarmodelo', async (req, res) => {
    try{
        // Obtener el path por params
        const folderPath = req.query.folderPath;

        // Verificar que la ruta de la carpeta es valida
        if (!fs.existsSync(folderPath)){
            return res.status(400).json({error: 'La ruta de la carpeta no es valida'});
        }

        // Leer los archivos dentro de la carpeta
        fs.readdir(folderPath, async (err, files) => {
            if (err){
                return res.status(500).json({error: 'Error leyendo la carpeta'});
            }

            // Verificar que la carpeta contenga archivos
            if (files.length === 0){
                return res.status(400).json({error: 'La carpeta no contiene archivos'});
            }

            // Filtrar solo los archivos CSV
            const csvFiles = files.filter(file => path.extname(file).toLowerCase() === '.csv');

            // formar un array con las rutas completas de los archivos csv
            const csvFilePaths = csvFiles.map(file => path.join(folderPath, file));

            // Llamar la funcion y mandar los archivos csv
            const resultado = await cargarTablas(csvFilePaths);

            if (resultado.success){
                return res.status(200).json({message: resultado.message});
            } else{
                return res.status(500).json({error: resultado.message});
            }
        });

    } catch (error){
        console.error('Error cargando las tablas', error);
        return res.status(500).json({error: 'Error cargando las tablas'});
    }


});

module.exports = router;