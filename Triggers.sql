/*a.	Cuando se ingrese un movimiento de tipo Transferencia, realizar un disparador que registre dicha 
transferencia en la tabla correspondiente, si la cuenta destino de la transferencia es una cuenta de otro 
banco (Externa), que registre como número de cuenta 99999, como nombre de banco ‘Banco Externo’ y como estado ‘Auditoria’.*/
CREATE TRIGGER auditMovimiento
ON Movimiento
AFTER INSERT
AS
BEGIN
	IF (Select TipoMovim
		From Inserted) = '' --???
	INSERT INTO Transferencia (FchTransfer, IdMovim, TipoTransfer, CtaDestino, BancoDestino, StatusTransfer)
		Values () --Hay que tomar los datos de inserted
END

/*b.	Crear un disparador que al modificarse el importe de un movimiento deje un registro en una tabla de auditoría, 
esta tabla debe tener la siguiente estructura:
Auditoria(idAudit,fchAudit,idMovim,idCliente,NombreCliente,ImporteAnterior,ImporteActual)
El campo idAudit debe ser autoincremental y fchAudit también debe registrar la hora*/
CREATE TRIGGER auditMovimiento
ON Movimiento
AFTER INSERT
AS
BEGIN
	
END

/*c.	Mediante el uso de un disparador, no permitir ingresar un Movimiento de Salida de una cuenta que no tenga saldo.*/
CREATE TRIGGER movimientoSalida
ON Movimiento
INSTEAD OF INSERT
AS
DECLARE
	@movim 
BEGIN
	IF NOT EXISTS (Select * 
				From Cuenta c, Movimiento m, Transferencia t
				Where c.idCuenta = m.idCuenta and
					m.IdMovim = t.IdMovim
					Cuenta.SaldoCuenta > 0 and
					t.TipoTransfer = 'S') --Ver el tipo de transaccion sea Salida
									--Tomar los valores de la tabla insert y eliminarlos
	
END

/*d.	Mediante un disparador, no permitir crear una nueva cuenta si el cliente ya tiene una cuenta en la misma moneda y en la misma sucursal.*/
CREATE TRIGGER cuentasRepetidas
ON Cuenta
INSTEAD OF INSERT
AS
BEGIN
	IF (Select IdCliente
		From Inserted) in (Select IdCliente
							From Cuenta) --No termine
END

/*e.	Implementar un disparador que controle el borrado de una sucursal, para permitir el mismo, dicho disparador debe 
“mover” antes todas las cuentas a la sucursal más antigua del banco (obtener la sucursal más antigua de acuerdo a los movimientos).*/

CREATE TRIGGER borradoSucursar
ON Sucursal
INSTEAD OF DELETE
AS
DECLARE 
	@sucursal char(5)
BEGIN
	Select top 1 @sucursal = s.IdSucursal
	From Sucursal s, Movimiento m, Cuenta c
	Where s.IdSucursal = c.IdSucursal and
			c.IdCuenta = m.IdCuenta
	Update Cuenta
	SET IdSucursal = @sucursal
	Where IdSucursal = (Select IdSucursal
						From deleted) --VER COMO SOLUCIONAR SI SE BORRA LA SUC MAS ANTIGUA
END
