//Importaciones
const oracledb = require('oracledb');
const { dbConfig } = require('../config');

// Funcion para ejecutar los procesos
async function ejecutarProcesos(nombreProceso) {
    try {
        // Realizar la conexión a la base de datos
        const connection = await oracledb.getConnection(dbConfig);

        // Realizar la consulta SQL para ejecutar el proceso
        const query = `
            BEGIN
                DBMS_OUTPUT.ENABLE(1000000);
                ${nombreProceso}();
            END;
        `;

        await connection.execute('BEGIN DBMS_OUTPUT.ENABLE(); END;');
        await connection.execute(query);

        // Obtener los mensajes de la salida del procedimiento almacenado
        let output = '';
        let bindvars = {
            line: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 32767 },
            status: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
        };

        do {
            const result = await connection.execute(
                `BEGIN DBMS_OUTPUT.GET_LINE(:line, :status); END;`,
                {
                    line: bindvars.line,
                    status: bindvars.status
                }
            );

            // Verificar si hay una línea de salida disponible
            let cadaline = '';
            if (result.outBinds.status === 0) {
                cadaline = result.outBinds.line;
                output += result.outBinds.line + '\n';
            }
            //si cadaline esta vacia entonces no hay mas lineas de salida y se sale del ciclo
            if (cadaline === '') {
                break;
            }

        } while (bindvars.line);

        // Cerrar la conexión
        await connection.close();

        // Dividir el output por el delimitador '-'
        const sections = output.split('-').filter(section => section.trim() !== '');

        // Inicializar un array para almacenar los objetos JSON resultantes
        const jsonResults = [];

        // Iterar sobre cada sección para procesarla y crear objetos JSON
        sections.forEach(section => {
            // Dividir cada sección en líneas individuales
            const lines = section.split('\n');
            // Inicializar un objeto JSON para almacenar los datos de la sección
            const sectionData = {};
            // Iterar sobre cada línea de la sección y agregar los datos al objeto JSON
            lines.forEach(line => {
                if (line.includes(':')) {
                    const [key, value] = line.split(':');
                    sectionData[key.trim()] = value.trim();
                } 
            });
            // Agregar el objeto JSON al array de resultados
            jsonResults.push(sectionData);
        });


        // Retornar el resultado
        return { success: true, message: 'Proceso ejecutado correctamente', data: jsonResults };

    } catch (error) {
        console.error('Error ejecutando el proceso', error);
        // Retornar un mensaje de error con el nombre del proceso
        return { success: false, message: 'Error ejecutando el proceso: ' + nombreProceso };
    }
}

// Exportar la función
module.exports = ejecutarProcesos;

