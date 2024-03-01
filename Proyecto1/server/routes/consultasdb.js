//Importacion de los paquetes y modulos a utilizar
const express = require('express');
const router = express.Router();
const ejecutarProcesos = require('../util/ejecutarProcesos')

// =============================================================== CONSULTA 1 ===============================================================

router.get('/consulta1', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA1');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 1'});

    } catch (error){
        console.error('Error en la consulta 1', error);
        return res.status(500).json({error: 'Error en la consulta 1'});
    }
    
});

// =============================================================== CONSULTA 2 ===============================================================

router.get('/consulta2', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA2');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 2'});

    } catch (error){
        console.error('Error en la consulta 2', error);
        return res.status(500).json({error: 'Error en la consulta 2'});
    }
    
});

// =============================================================== CONSULTA 3 ===============================================================

router.get('/consulta3', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA3');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 3'});

    } catch (error){
        console.error('Error en la consulta 3', error);
        return res.status(500).json({error: 'Error en la consulta 3'});
    }
    
});

// =============================================================== CONSULTA 4 ===============================================================

router.get('/consulta4', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA4');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 4'});

    } catch (error){
        console.error('Error en la consulta 4', error);
        return res.status(500).json({error: 'Error en la consulta 4'});
    }
    
});

// =============================================================== CONSULTA 5 ===============================================================

router.get('/consulta5', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA5');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 5'});

    } catch (error){
        console.error('Error en la consulta 5', error);
        return res.status(500).json({error: 'Error en la consulta 5'});
    }
    
});

// =============================================================== CONSULTA 6 ===============================================================

router.get('/consulta6', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA6');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 6'});

    } catch (error){
        console.error('Error en la consulta 6', error);
        return res.status(500).json({error: 'Error en la consulta 6'});
    }
    
});

// =============================================================== CONSULTA 7 ===============================================================

router.get('/consulta7', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA7');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 7'});

    } catch (error){
        console.error('Error en la consulta 7', error);
        return res.status(500).json({error: 'Error en la consulta 7'});
    }
    
}  );

// =============================================================== CONSULTA 8 ===============================================================

router.get('/consulta8', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA8');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 8'});

    } catch (error){
        console.error('Error en la consulta 8', error);
        return res.status(500).json({error: 'Error en la consulta 8'});
    }
    
});

// =============================================================== CONSULTA 9 ===============================================================

router.get('/consulta9', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA9');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 9'});

    } catch (error){
        console.error('Error en la consulta 9', error);
        return res.status(500).json({error: 'Error en la consulta 9'});
    }
    
});

// =============================================================== CONSULTA 10 ===============================================================

router.get('/consulta10', async (req, res) => {
    try{
        // Llamar la funcion para ejecutar el proceso
        const resultado = await ejecutarProcesos('CONSULTA10');

        if (resultado.success){
            return res.status(200).json(resultado.data);
        }
        return res.status(500).json({error: 'Error en la consulta 10'});

    } catch (error){
        console.error('Error en la consulta 10', error);
        return res.status(500).json({error: 'Error en la consulta 10'});
    }
    
});


module.exports = router;