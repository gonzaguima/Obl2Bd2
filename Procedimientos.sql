/*OBLIGATORIO 2*/

-- 1) Crear procedimientos o funciones según corresponda para:

--A) a.	Crear un procedimiento almacenado ‘SaldosDeCuentaCliente' que reciba como parámetros un número de cuenta y
-- un rango de fechas y retorne por parámetros de salida el saldo anterior a la fecha inicial del rango y el saldo actual a la fecha final del rango.
CREATE PROCEDURE SaldosDeCuentaCliente 
@cuenta int, @desde character(10), @hasta character(10), @saldoinicial int output, @saldofinal int output
AS
BEGIN
	SELECT @saldoinicial = ISNULL((SELECT SUM(ImporteMovim)
							FROM Movimiento m
							WHERE m.IdCuenta = @cuenta AND
								  m.FchMovim <= @desde), 0)

	SELECT @saldofinal = ISNULL((SELECT SUM(ImporteMovim)
							FROM Movimiento m
							WHERE m.IdCuenta = @cuenta AND
								  m.FchMovim  <= @hasta),0)

END

--B) Agregar a la tabla Cuentas una campo SaldoCuenta y crear un procedimiento almacenado 'generarSaldos', 
--que permita cargar el saldo de la cuenta de acuerdo a los movimientos que tiene.

ALTER TABLE Cuenta
ADD SaldoCuenta money


CREATE PROCEDURE generarSaldos 
AS
BEGIN
	UPDATE Cuenta
	
	SET SaldoCuenta = ISNULL((SELECT SUM(importeMovim)
					  FROM Movimiento
					  WHERE cuenta.IdCuenta = Movimiento.IdCuenta AND
					  Movimiento.TipoMovim = 'E'), 0) - ISNULL((SELECT SUM(importeMovim)
													  FROM Movimiento
													  WHERE cuenta.IdCuenta = Movimiento.IdCuenta AND
													  Movimiento.TipoMovim IN ('S', 'T')), 0)
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
						WHERE DSCMONEDA LIKE '%Dollars%'

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

	IF ISNULL(@ENTRADAS, 0) < ISNULL(@SALIDAS,0)
	BEGIN
		SELECT @NOMBRECLIENTE = NOMBRECLIENTE
		FROM CLIENTE
		WHERE IdCliente = @IDCLIENTE
		SET @IMPORTE = @ENTRADAS - @SALIDAS
	END
	
END


