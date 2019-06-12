-- 3) CREAR LAS SIGUIENTES VISTAS:

--A: Crear una vista que muestre la cantidad de depósitos que tiene el banco para cada uno de los meses del año actual.
CREATE VIEW cantDepositosMensual
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

select * from cantDepositosMensual

SELECT Mes, (Select Count(IdMovim)
					From Movimiento
					Where YEAR(GETDATE()) = YEAR(FchMovim) and
							MONTH(FchMovim) = Mes and
							TipoMovim = 'E') as Cant
From (SELECT DISTINCT Mes = number 
	  FROM master..[spt_values] 
	  WHERE number BETWEEN 1 AND 12) Mes

--select * from cantDepositosMensual


--B: b.	crear una vista que muestre para cada cliente la cantidad de movimientos que ha realizado discriminado por tipo de movimiento 
--y la fecha del último movimiento realizado en cada uno de esos tipos de movimientos. En el resultado deben aparecer todos los clientes
CREATE VIEW clienteCantMovim
AS
Select NombreCliente, (Select Count(IdMovim)
						From Movimiento m, Cuenta c
						Where m.IdCuenta = c.IdCuenta and
								c.IdCliente = cli.IdCliente and
								TipoMovim = 'E') AS Cant_Entradas,
					(Select MAX(FchMovim)
						From Movimiento m, Cuenta c
						Where m.IdCuenta = c.IdCuenta and
								c.IdCliente = cli.IdCliente and
								TipoMovim = 'E') AS Fecha_Entradas,
									(Select Count(IdMovim)
						From Movimiento m, Cuenta c
						Where m.IdCuenta = c.IdCuenta and
								c.IdCliente = cli.IdCliente and
								TipoMovim = 'S') AS Cant_Salidas,
					(Select MAX(FchMovim)
						From Movimiento m, Cuenta c
						Where m.IdCuenta = c.IdCuenta and
								c.IdCliente = cli.IdCliente and
								TipoMovim = 'S') AS Fecha_Salidas,
									(Select Count(IdMovim)
						From Movimiento m, Cuenta c
						Where m.IdCuenta = c.IdCuenta and
								c.IdCliente = cli.IdCliente and
								TipoMovim = 'T') AS Cant_Transfer,
					(Select MAX(FchMovim)
						From Movimiento m, Cuenta c
						Where m.IdCuenta = c.IdCuenta and
								c.IdCliente = cli.IdCliente and
								TipoMovim = 'T') AS Fecha_Transfer
From Cliente cli


--select * from clienteCantMovim