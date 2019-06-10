-- 3) CREAR LAS SIGUIENTES VISTAS:

--A: Crear una vista que muestre la cantidad de depósitos que tiene el banco para cada uno de los meses del año actual.
CREATE VIEW cantDepositosMensual
AS
SELECT DISTINCT (MONTH (V.FchMovim)) AS Mes,
								   (SELECT COUNT(IdMovim)
									FROM  Movimiento M
									WHERE TipoMovim = 'E' AND
									V.FchMovim = M.FchMovim
									GROUP BY M.FchMovim
									) AS Cant_Depo
FROM Movimiento V
WHERE YEAR(V.FchMovim) = YEAR(GETDATE())

--select * from cantDepositosMensual
--muestra varias veces el mismo mes, aunque se use distinct

--B: b.	crear una vista que muestre para cada cliente la cantidad de movimientos que ha realizado discriminado por tipo de movimiento 
--y la fecha del último movimiento realizado en cada uno de esos tipos de movimientos. En el resultado deben aparecer todos los clientes
