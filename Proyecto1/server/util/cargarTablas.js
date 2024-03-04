const oracledb = require('oracledb');
const { dbConfig } = require('../config');
const fs = require('fs');
const csv = require('csv-parser');

// Funcion para cargar las tablas

async function cargarTablas(csvFilePaths) {
    try {
        // Conexion a la base de datos
        const connection = await oracledb.getConnection(dbConfig);

        //Lista de tablas deseadas
        //const tablasDeseadas = ['ORDEN'];
        const tablasDeseadas = ['PAIS', 'CATEGORIA', 'CLIENTE', 'VENDEDOR', 'PRODUCTO', 'ORDEN', 'ORDENE'];
        //const tablasDeseadas = ['PAIS', 'CATEGORIA', 'CLIENTE', 'VENDEDOR', 'PRODUCTO'];

        // recorrer las tablas deseadas
        for (const tabla of tablasDeseadas) {
            const tablaFilePath = csvFilePaths.find(filePath => {
                const regex = new RegExp(`${tabla}`, 'i');
                return regex.test(filePath);
            });

            // Verificar que se haya encontrado el archivo
            if (!tablaFilePath) {
                return { success: false, message: `No se encontró el archivo para la tabla ${tabla}` };
            }

            // Retornar el nombre de la tabla
            console.log(`Cargando la tabla ${tabla} desde el archivo ${tablaFilePath}`);

            //Leer el archivo CSV y cargar los datos en la tabla con consultas sql
            const stream = fs.createReadStream(tablaFilePath);
            await new Promise((resolve, reject) => {
                stream.pipe(csv({ separator: ';' }))
                    .on('data', async (row) => {
                        try {
                            //const keys = Object.keys(row).map(limpiarCadena);
                            const values = Object.values(row).map(value => {
                                // Envuelve todos los valores en comillas simples
                                const cleanedValue = value.replace(/'/g, '').replace(/\//g, '-');
                                //const cleanedValue = value.replace(/'/g, "''");

                                //si viene un valor de fecha tipo 20-02-2024 o 1-03-2024, devolverlo de esta manera TO_DATE('fecha', 'DD-MM-YYYY') o 
                                if (cleanedValue.match(/\d{2}-\d{2}-\d{4}/)) {
                                    return `TO_DATE('${cleanedValue}', 'DD-MM-YYYY')`;
                                } else if (cleanedValue.match(/\d{1}-\d{2}-\d{4}/)) {
                                    //agregar el 0 al dia
                                    return `TO_DATE('0${cleanedValue}', 'DD-MM-YYYY')`;
                                }
                                return `'${cleanedValue}'`;
                            });
                            let sql = '';
                            let sql1 = '';
                            if (tabla === 'ORDEN') {
                                sql = `INSERT INTO "SBD1P1"."DETALLE_ORDEN" VALUES (${values[0]}, ${values[1]}, ${values[4]}, ${values[5]}, ${values[6]})`;
                                await connection.execute(sql);
                            }else if(tabla === 'ORDENE'){
                                if(values[1] == "'1'"){
                                    sql = `INSERT INTO "SBD1P1"."ORDEN" VALUES (${values[0]}, ${values[2]}, ${values[3]}, ${values[1]})`;
                                    await connection.execute(sql);
                                }
                            }else{
                                sql = `INSERT INTO "SBD1P1"."${tabla}" VALUES (${values.join(',')})`;
                                await connection.execute(sql);
                            }
                            //await connection.commit();

                        } catch (error) {
                            console.error('Error cargando la tabla', tabla, error);
                            reject(error);
                        }
                    })
                    .on('end', async () => {
                        console.log(`Tabla ${tabla} cargada exitosamente`);
                        resolve();
                    })
                    .on('error', (error) => {
                        console.error('Error cargando la tabla', tabla, error);
                        reject(error);
                    });

            });
        }
        await connection.commit();
        await connection.close();
        return { success: true, message: 'Tablas cargadas exitosamente' };

    } catch (error) {
        console.error('Error cargando las tablas', error);
        return { success: false, message: 'Error cargando las tablas' };
    }
}

// Exportar la funcion
module.exports = cargarTablas;