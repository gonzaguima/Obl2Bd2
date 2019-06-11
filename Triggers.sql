/*a.	Cuando se ingrese un movimiento de tipo Transferencia, realizar un disparador que registre dicha 
transferencia en la tabla correspondiente*/
CREATE TRIGGER auditMovimiento
ON Movimiento
AFTER INSERT --AGARRAR EL "C" E INCERTAR LOS QUE SON DE TIPO T
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
BEGIN
	INSERT INTO Movimiento Select i.FchMovim, i.TipoMovim, i.IdCuenta, i.ImporteMovim
							From inserted i, Cuenta c
							Where i.IdCuenta = c.IdCuenta and
								(i.TipoMovim IN ('S', 'T') and
								i.ImporteMovim <= c.SaldoCuenta) or
								i.TipoMovim = 'E'
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

ALTER TRIGGER borradoSucursar
ON Sucursal
INSTEAD OF DELETE
AS
DECLARE 
	@sucVieja char(5), @sucDel char(5)
BEGIN
	Select top 1 @sucVieja = s.IdSucursal
	From Sucursal s, Movimiento m, Cuenta c
	Where s.IdSucursal = c.IdSucursal and --Buscar la mas vieja por las fechas de movimientos
			c.IdCuenta = m.IdCuenta

	Select @sucDel = IdSucursal
	From deleted

	IF @sucDel = @sucVieja
	BEGIN
		Select top 1 @sucVieja = s.IdSucursal
		From Sucursal s, Movimiento m, Cuenta c
		Where s.IdSucursal = c.IdSucursal and
				c.IdCuenta = m.IdCuenta and 
				s.IdSucursal != @sucVieja
	END

	Update Cuenta
	SET IdSucursal = @sucVieja
	Where IdSucursal = @sucDel

	DELETE From Sucursal
	Where IdSucursal = @sucDel
END
