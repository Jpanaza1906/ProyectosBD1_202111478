-- CONSULTA DE SALDO CLIENTE CON NO.CUENTA
BEGIN
    consultarSaldoCliente(1);
end;
/

-- CONSULTA DE LA INFORMACION DE CLIENTE CON ID_CLIENTE
BEGIN
    consultarCliente(3);
end;
/

-- CONSULTA DE TODOS LOS MOVIMIENTOS DE UN CLIENTE CON ID_CLIENTE
BEGIN
    consultarMovsCliente(2);
end;
/

-- CONSULTA DE CLIENTES POR TIPO DE CUENTA
BEGIN
    consultarTipoCuentas(2);
end;

-- CONSULTAR LOS MOVIMIENTOS POR FECHAS

BEGIN
    consultarMovsGenFech('','28/03/2024');
end;

-- CONSULTAR LOS MOVIMIENTOS POR FECHAS Y CLIENTE
BEGIN
    consultarMovsFechClien(1, '26/03/2024', '28/03/2024');
end;

--CONSULTAR PRODUCTOS Y SERVICIOS
BEGIN
    consultarDesasignacion();
end;