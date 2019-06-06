/*a.	Cuando se ingrese un movimiento de tipo Transferencia, realizar un disparador que registre dicha 
transferencia en la tabla correspondiente, si la cuenta destino de la transferencia es una cuenta de otro 
banco (Externa), que registre como número de cuenta 99999, como nombre de banco ‘Banco Externo’ y como estado ‘Auditoria’.*/


/*b.	Crear un disparador que al modificarse el importe de un movimiento deje un registro en una tabla de auditoría, esta tabla debe tener la siguiente estructura:
Auditoria(idAudit,fchAudit,idMovim,idCliente,NombreCliente,ImporteAnterior,ImporteActual)
El campo idAudit debe ser autoincremental y fchAudit también debe registrar la hora*/


/*c.	Mediante el uso de un disparador, no permitir ingresar un Movimiento de Salida de una cuenta que no tenga saldo.*/
CREATE TRIGGER movimientoSalida
ON Movimiento
AFTER INSERT
AS
BEGIN
	IF NOT EXISTS (Select * 
				From Cuenta
				Where Cuenta.SaldoCuenta > 0 and
					Cuenta.IdTipo) --Ver el tipo de transaccion sea Salida
									--Tomar los valores de la tabla insert y eliminarlos
END

/*d.	Mediante un disparador, no permitir crear una nueva cuenta si el cliente ya tiene una cuenta en la misma moneda y en la misma sucursal.*/


/*e.	Implementar un disparador que controle el borrado de una sucursal, para permitir el mismo, dicho disparador debe 
“mover” antes todas las cuentas a la sucursal más antigua del banco (obtener la sucursal más antigua de acuerdo a los movimientos).*/

Select top 1 s.IdSucursal --La sucursal mas antigua
From Sucursal s, Movimiento m, Cuenta c
Where s.IdSucursal = c.IdSucursal and
		c.IdCuenta = m.IdCuenta