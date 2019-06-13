/*a.	Cuando se ingrese un movimiento de tipo Transferencia, realizar un disparador que registre dicha 
transferencia en la tabla correspondiente*/

CREATE TRIGGER MovimientoTransfer
ON Movimiento
AFTER INSERT --AGARRAR EL "C" E INSERTAR LOS QUE SON DE TIPO T
AS
BEGIN
	INSERT INTO Transferencia Select i.FchMovim, i.IdMovim, null, i.IdCuenta, null, null
								From inserted i, Cuenta c
								Where i.IdCuenta = c.IdCuenta and
									(i.TipoMovim IN ('T'))
END

/*b.	Crear un disparador que al modificarse el importe de un movimiento deje un registro en una tabla de auditor�a, 
esta tabla debe tener la siguiente estructura:
Auditoria(idAudit,fchAudit,idMovim,idCliente,NombreCliente,ImporteAnterior,ImporteActual)
El campo idAudit debe ser autoincremental y fchAudit tambi�n debe registrar la hora*/
CREATE TABLE Auditoria(idAudit int not null identity,
						fchAudit datetime,
						idMovim numeric(5,0) Foreign key references Movimiento(IdMovim),
						idCliente numeric(5,0) Foreign key references Cliente(IdCliente),
						NombreCliente varchar(30),
						ImporteAnterior int,
						ImporteActual int)


CREATE TRIGGER auditMovimiento
ON Movimiento
AFTER UPDATE
AS
BEGIN
	INSERT INTO Auditoria 
	Select i.IdMovim, c.IdCuenta, cli.NombreCliente, c.SaldoCuenta as ImporteActual, 
				(c.SaldoCuenta - i.ImporteMovim) as ImporteAnterior
	From inserted i, Cuenta c, Cliente cli
	Where i.IdCuenta = c.IdCuenta and
			c.IdCliente = cli.IdCliente
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

/*d.	Mediante un disparador, no permitir crear una nueva cuenta si 
el cliente ya tiene una cuenta en la misma moneda y en la misma sucursal.*/
CREATE TRIGGER cuentasRepetidas
ON Cuenta
INSTEAD OF INSERT
AS
BEGIN
	IF (Select IdCliente
		From Inserted) in (Select IdCliente
							From Cuenta c, Sucursal s
							Where c.IdSucursal = s.IdSucursal and
									c.IdMoneda != (Select IdMoneda
													From inserted))
	BEGIN
		INSERT INTO Cuenta Select IdTipo, IdMoneda, IdSucursal, IdCliente 
							from inserted
	END
END

/*e.	Implementar un disparador que controle el borrado de una sucursal, para permitir el mismo, dicho disparador debe 
�mover� antes todas las cuentas a la sucursal m�s antigua del banco (obtener la sucursal m�s antigua de acuerdo a los movimientos).*/

ALTER TRIGGER borradoSucursar
ON Sucursal
INSTEAD OF DELETE
AS
DECLARE 
	@sucVieja char(5), @sucDel char(5)
BEGIN
	Select Top 1 @sucVieja = s.IdSucursal
	From Sucursal s, Movimiento m, Cuenta c
	Where s.IdSucursal = c.IdSucursal and
			c.IdCuenta = m.IdCuenta
	Order by m.FchMovim

	Select @sucDel = IdSucursal
	From deleted

	IF @sucDel = @sucVieja
	BEGIN
		Select top 1 @sucVieja = s.IdSucursal
		From Sucursal s, Movimiento m, Cuenta c
		Where s.IdSucursal = c.IdSucursal and
				c.IdCuenta = m.IdCuenta and 
				s.IdSucursal != @sucVieja
		Order by m.FchMovim
	END

	Update Cuenta
	SET IdSucursal = @sucVieja
	Where IdSucursal = @sucDel

	DELETE From Sucursal
	Where IdSucursal = @sucDel
END
