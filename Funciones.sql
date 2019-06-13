--1)
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



-- D) Crear una función ‘maximoSaldoCliente’ que dado un cliente y
-- una moneda retorne el máximo saldo que en el corriente año tuvo dicho cliente para dicha moneda.

alter FUNCTION MAXIMOSALDOCLIENTE (@IDCLIENTE INT, @IDMONEDA INT)
	RETURNS MONEY
AS
BEGIN
DECLARE @RETORNO MONEY, @ENTRADAS MONEY, @SALIDAS MONEY
	SELECT @ENTRADAS = MAX(ENTRADAS.ENTRADA), @SALIDAS = MAX(SALIDAS.SALIDA)
	FROM(SELECT C.IDCUENTA, SUM(IMPORTEMOVIM)AS ENTRADA
		FROM CUENTA C, MOVIMIENTO M
		WHERE C.IDCUENTA = M.IDCUENTA AND
			  C.IDMONEDA = @IDMONEDA AND
			  C.IDCLIENTE = @IDCLIENTE AND 
			  M.TIPOMOVIM = 'E'
		GROUP BY C.IDCUENTA
		) ENTRADAS, 
		( SELECT C.IDCUENTA, SUM(IMPORTEMOVIM) AS SALIDA
			FROM CUENTA C, MOVIMIENTO M
			WHERE C.IDCUENTA = M.IDCUENTA AND
				  C.IDMONEDA = @IDMONEDA AND
				  C.IDCLIENTE = @IDCLIENTE AND 
				  M.TIPOMOVIM IN ('S', 'T')
			GROUP BY C.IDCUENTA) SALIDAS
	WHERE ENTRADAS.IDCUENTA = SALIDAS.IDCUENTA

	RETURN @ENTRADAS - @SALIDAS
END

