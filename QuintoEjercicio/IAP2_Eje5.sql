DECLARE		@cadena1		VARCHAR(50),
			@len1			INT,
			@cadena2		VARCHAR(50),
			@len2			INT,
			@cont			INT,
			@letra			VARCHAR(20),
			@sql			NVARCHAR(4000),
			@columna		NVARCHAR(10),
			@cons1			NVARCHAR(4000),
			@len			INT,
			@suma_column	INT,
			@suma			INT,
			@nom_column		VARCHAR(50)

SET @cadena1 = 'martha'
SET @cont = 1
SELECT @len1 = LEN(@cadena1)
SET @sql = 'CREATE TABLE nombre ('
WHILE @cont <= @len1
BEGIN
	SET @letra = LEFT(@cadena1, 1) + CAST(@cont AS VARCHAR(1)) + ' INT,'
	SET @cadena1 = RIGHT(@cadena1, LEN(@cadena1)-1)
	SET @sql = @sql + @letra
	SET @cont = @cont + 1
END
SET @sql = LEFT(@sql, LEN(@sql) - 1)
SET @sql = @sql+')'

EXEC sp_executesql @sql

SET @cadena2 = 'marta'
SET @cont = 1
SELECT @len2 = LEN(@cadena2)
WHILE @cont <= @len2
BEGIN
	SET @letra = LEFT(@cadena2, 1)
	SET @cadena2 = RIGHT(@cadena2, LEN(@cadena2) - 1)
	SET @columna = (SELECT TOP 1 COLUMN_NAME
					FROM INFORMATION_SCHEMA.COLUMNS	
					WHERE TABLE_NAME = 'nombre'
					AND LEFT(COLUMN_NAME, 1) = @letra
					AND ORDINAL_POSITION >= @cont)
	SET @sql = 'INSERT INTO nombre('+@columna+') values(1)'
	EXEC sp_executesql @sql
	SET @cont = @cont + 1
END

SET @len = (SELECT COUNT(COLUMN_NAME)
			FROM INFORMATION_SCHEMA.COLUMNS	
			WHERE TABLE_NAME = 'nombre')
SET @cont = 1
SET @cons1 = 'SELECT '
WHILE @len >= @cont
BEGIN
	SET @nom_column = (select COLUMN_NAME 
					   FROM INFORMATION_SCHEMA.COLUMNS
					   WHERE TABLE_NAME = 'nombre'
					   AND ORDINAL_POSITION = @cont)
	SET @cons1 = @cons1 + 'COALESCE(SUM(' + @nom_column + '),0)+'
	SET @cont = @cont + 1
END
SET @cons1 = LEFT(@cons1, LEN(@cons1) - 1)
SET @cons1 = @cons1 + ' FROM nombre'
EXEC sp_executesql @cons1

SELECT * FROM nombre
DROP TABLE nombre