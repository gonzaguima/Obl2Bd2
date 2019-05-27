/*OBLIGATORIO 2*/

--1)
-- deberia ser funcion para poder retornar?
CREATE PROCEDURE SaldosDeCuentaCliente 
@cuenta int, @desde character(10), @hasta character(10)
AS
BEGIN
	
	PRINT 'X' + asd
END


--2)
ALTER TABLE Cuenta
ADD SaldoCuenta money

CREATE PROCEDURE generarSaldos
AS
BEGIN
	UPDATE Cuenta
	
	SET SaldoCuenta = (SELECT SUM(ImporteMovim)
					  FROM Movimiento
					  WHERE cuenta.IdCuenta = Movimiento.IdCuenta)
END


ALTER PROCEDURE generarSaldos 
AS
BEGIN
	UPDATE Cuenta
	
	SET SaldoCuenta = (SELECT SUM(importeMovim)
					  FROM Movimiento
					  WHERE cuenta.IdCuenta = Movimiento.IdCuenta AND
					  Movimiento.TipoMovim = 'E') - (SELECT SUM(importeMovim)
													  FROM Movimiento
													  WHERE cuenta.IdCuenta = Movimiento.IdCuenta AND
													  Movimiento.TipoMovim IN ('S', 'T'))
END

select * from cuenta

EXECUTE generarSaldos

--3)

CREATE FUNCTION verSaldoCuenta(@idCuenta INT, @fecha character(10))
	RETURNS INT
AS
BEGIN
DECLARE @RESULTADO INT
	SET @RESULTADO = (SELECT SUM(importeMovim)
					  FROM Movimiento
					  WHERE @IdCuenta = Movimiento.IdCuenta AND
					  Movimiento.TipoMovim = 'E' AND
					  @fecha >= Movimiento.FchMovim) - (SELECT SUM(importeMovim)
													   FROM Movimiento
													   WHERE @IdCuenta = Movimiento.IdCuenta AND
													   Movimiento.TipoMovim IN ('S', 'T')AND
													   @fecha >= Movimiento.FchMovim)

	RETURN @RESULTADO
END


SELECT DBO.verSaldoCuenta(1, '15/12/2019')

--4)

