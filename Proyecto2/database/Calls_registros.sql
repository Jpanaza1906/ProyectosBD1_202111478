-- REGISTRO DE TIPOS

BEGIN
    registrarTipoCliente('Empresa S.C', 'Este tipo de cliente corresponde a las empresas grandes que tienen una sociedad colectiva.');
END;
/

BEGIN
    registrarTipoCuenta('Cuenta de Inversión', 'Orientada a inversionistas, ofrece opciones de inversión y rendimientos más altos que una cuenta de ahorros estándar.');
END;
/

BEGIN
    registrarTipoTransaccion('Debito', 'Esta transaccion indica un debito desde una cuenta.');
end;
/

-- REGISTRO DE CLIENTE

BEGIN
    registrarCliente(2,'David', 'Batres', '50222000000', 'davidbatres@gmail.com', 'dbatres', 'hola',2);
end;
/

-- REGISTRO DE CUENTA
--Validar saldos y que pueda o no venir la fecha de apertura
BEGIN
    registrarCuenta(4,500,500,'Cuenta','27/03/2024 13:23:33','',2,1);
end;
/

-- CREAR PRODUCTO O SERVICIO
BEGIN
    crearProductoServicio(17,2,0,'Servicios Cloud');
end;
/

-- REALIZAR COMPRA

BEGIN
    realizarCompra(1,'27/03/2024',0,'',1,1);
end;
/
-- REALIZAR DEPOSITO

BEGIN
    realizarDeposito(1,'27/03/2024',1000,'',1);
end;
/
-- REALIZAR DEBITO
BEGIN
    realizarDebito(2,'27/03/2024',300,'',2);
end;
/
-- ASIGNAR TRANSACCION
BEGIN
    asignarTransaccion('27/03/2024','',2,2,1);
end;
/
