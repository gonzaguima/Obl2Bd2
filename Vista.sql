-- 3) CREAR LAS SIGUIENTES VISTAS:

--A: Crear una vista que muestre la cantidad de depósitos que tiene el banco para cada uno de los meses del año actual.
ALTER VIEW cantDepositosMensual
AS
SELECT DISTINCT MONTH (V.FchMovim) AS Mes,(SELECT COUNT(IdMovim)
											FROM  Movimiento M
											WHERE TipoMovim = 'E' AND
											V.FchMovim = M.FchMovim
											GROUP BY M.FchMovim
											) AS Cant_Depo
FROM Movimiento V
WHERE YEAR(V.FchMovim) = YEAR(GETDATE())
Group by V.FchMovim

SELECT Mes, Nombre, (Select Count(IdMovim)
					From Movimiento
					Where YEAR(GETDATE()) = YEAR(FchMovim) and
							MONTH(FchMovim) = Mes and
							TipoMovim = 'E') as Cant
From (subconsulta de meses) Mes

--select * from cantDepositosMensual
--muestra varias veces el mismo mes, aunque se use distinct

--B: b.	crear una vista que muestre para cada cliente la cantidad de movimientos que ha realizado discriminado por tipo de movimiento 
--y la fecha del último movimiento realizado en cada uno de esos tipos de movimientos. En el resultado deben aparecer todos los clientes

Select NombreCliente, (Select Count(IdMovim)
						From Movimiento m, Cuenta c
						Where m.IdCuenta = c.IdCuenta and
								c.IdCliente = cli.IdCliente and
								TipoMovim = 'E') AS Entradas,
					(Select MAX(FchMovim)
						From Movimiento m, Cuenta c
						Where m.IdCuenta = c.IdCuenta and
								c.IdCliente = cli.IdCliente and
								TipoMovim = 'S') AS Fecha
From Cliente cli