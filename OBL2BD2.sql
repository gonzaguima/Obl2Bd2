/*OBLIGATORIO 2*/

-- 1) Crear procedimientos o funciones según corresponda para:

--A) a.	Crear un procedimiento almacenado ‘SaldosDeCuentaCliente' que reciba como parámetros un número de cuenta y
-- un rango de fechas y retorne por parámetros de salida el saldo anterior a la fecha inicial del rango y el saldo actual a la fecha final del rango.
CREATE PROCEDURE SaldosDeCuentaCliente 
@cuenta int, @desde character(10), @hasta character(10), @saldoinicial int output, @saldofinal int output
AS
BEGIN
	SELECT @saldoinicial = (SELECT SUM(ImporteMovim)
							FROM Movimiento m
							WHERE m.IdCuenta = @cuenta AND
								  m.FchMovim <= @desde)

	SELECT @saldofinal = (SELECT SUM(ImporteMovim)
							FROM Movimiento m
							WHERE m.IdCuenta = @cuenta AND
								  m.FchMovim  >= @hasta)

END

EXECUTE saldosdecuentacliente 1, '01/01/19', '31/12/19'

--B) Agregar a la tabla Cuentas una campo SaldoCuenta y crear un procedimiento almacenado 'generarSaldos', 
--que permita cargar el saldo de la cuenta de acuerdo a los movimientos que tiene.

ALTER TABLE Cuenta
ADD SaldoCuenta money

--CREATE PROCEDURE generarSaldos
--AS
--BEGIN
--	UPDATE Cuenta
	
--	SET SaldoCuenta = (SELECT SUM(ImporteMovim)
--					  FROM Movimiento
--					  WHERE cuenta.IdCuenta = Movimiento.IdCuenta)
--END


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

--C) Implementar una función ‘verSaldoCuenta’, que reciba como parámetros una cuenta y  
-- una fecha y retorne el saldo de dicha cuenta a la fecha indicada, no puede utilizar el campo SaldoCuenta.

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

-- D) Crear una función ‘maximoSaldoCliente’ que dado un cliente y
-- una moneda retorne el máximo saldo que en el corriente año tuvo dicho cliente para dicha moneda.

CREATE FUNCTION MAXIMOSALDOCLIENTE (@IDCLIENTE INT, @IDMONEDA INT)
	RETURNS MONEY
AS
BEGIN
DECLARE @RETORNO MONEY
	SELECT @ENTRADAS = MAX(ENTRADAS.ENTRADA, @SALIDAS = MAX(SALIDAS.SALIDA)
	FROM(SELECT C.IDCUENTA, SUM(IMPORTEMOVIM)AS ENTRADA
		FROM CUENTA C, MOVIMIENTO M
		WHERE C.IDCUENTA = M.IDCUENTA AND
			  C.IDMONEDA = @IDMONEDA AND
			  C.IDCLIENTE = @IDCLIENTE AND 
			  M.TIPOMOVIM = 'E'
		GROUP BY C.IDCUENTA
		) ENTRADAS, 
		( SELECT C.IDCUENTA, SUM(IMPORTEMOVIM) AS SALIDA
			WHERE C.IDCUENTA = M.IDCUENTA AND
				  C.IDMONEDA = @IDMONEDA AND
				  C.IDCLIENTE = @IDCLIENTE AND 
				  M.TIPOMOVIM IN ('S', 'T')
			GROUP BY C.IDCUENTA) SALIDAS
	WHERE ENTRADAS.IDCUENTA = SALIDAS.IDCUENTA

	RETURN @ENTRADAS - @SALIDAS
END


-- E) Crear un procedimiento o función ‘sobregiroClienteUSD’, según corresponda, 
--que reciba un idCliente y retorne nombreCliente e importe de sobregiro en dólares de dicho cliente al día de hoy.

CREATE PROCEDURE SOBREGIROCLIENTEUSD
@IDCLIENTE INT, @NOMBRECLIENTE VARCHAR(30) OUTPUT, @IMPORTE MONEY OUTPUT
AS
BEGIN
DECLARE @ENTRADAS MONEY, @SALIDAS MONEY , @IDMONEDA INT
	SELECT @IDMONEDA = IDMONEDA
	FROM MONEDA
	WHERE DSCMONEDA LIKE '%DOLAR%'
	SELECT @ENTRADAS = SUM(IMPORTEMOVIM) 
	FROM MOVIMIENTO M, CUENTA C
	WHERE M.IdCuenta = C.IdCuenta AND
	C.IdCliente = @IDCLIENTE AND
	C.IdMoneda = @IDMONEDA AND
	M.TipoMovim = 'E'

	SELECT @SALIDAS = SUM(IMPORTEMOVIM) 
	FROM MOVIMIENTO M, CUENTA C
	WHERE M.IdCuenta = C.IdCuenta AND
	C.IdCliente = @IDCLIENTE AND
	C.IdMoneda = @IDMONEDA AND
	M.TipoMovim IN ('S', 'T')

	IF @ENTRADAS < @SALIDAS
	BEGIN
		SELECT @NOMBRECLIENTE = NOMBRECLIENTE
		FROM CLIENTE
		WHERE IdCliente = @IDCLIENTE
		SET @IMPORTE = @ENTRADAS - @SALIDAS
	END

END

--otra

SELECT @RETORNO = MAX(SALDOS.SALDO)
FROM(SELECT M.DCHMOVIM, DBO.VERSALDOCUENTA(M.IDCUENTA, M.FCHMOVIM )AS SALDO
WHERE M.IDCUENTA =C.IDCUENTA AND C.IDCLIENTE = @IDCLIENTE AND C.IDMONEDA = @IDMONEDA
	AND YEAR(M.FCHMOVIM) = YEAR(GETDATE())
GROUP BY M.FCHMOVIM).SALDOS