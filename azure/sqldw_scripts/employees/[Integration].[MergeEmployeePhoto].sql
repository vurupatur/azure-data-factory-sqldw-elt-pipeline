EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MergeEmployeePhoto'

PRINT 'Creating procedure [Integration].[MergeEmployeePhoto]'
GO

CREATE PROCEDURE [Integration].[MergeEmployeePhoto] AS
BEGIN
 DECLARE @MaxRowCount int = (
	SELECT MAX(a.[RowCount])
	FROM (
			SELECT COUNT(*) AS [RowCount]
				FROM [Integration].[EmployeePhoto_Staging]
			GROUP BY [WWI Employee ID]
			) a
	)
 
	DECLARE @PivotColumns nvarchar(max) = '[1]'
	DECLARE @ColumnCount int
	SET @ColumnCount = 2
	WHILE @ColumnCount <= @MaxRowCount
	BEGIN
	  SET @PivotColumns = @PivotColumns + ', ' + QUOTENAME(CONVERT(nvarchar(5), @ColumnCount))
	  SET @ColumnCount += 1
	END
 
   PRINT @PivotColumns

	DECLARE @Sql nvarchar(max) =
	N'
	CREATE TABLE EmployeePhotoHolder
	WITH (HEAP , DISTRIBUTION = HASH([WWI Employee ID]))
	AS

	SELECT [WWI Employee ID], CONVERT(varbinary(max), CONCAT(NULL, ' + @PivotColumns + ')) AS [Photo], [Valid From]
	  FROM (
		SELECT b.[WWI Employee ID], b.[Block ID], cls.[Photo],b.[Valid From]
		FROM (
		  SELECT DISTINCT cls.[WWI Employee ID], a.[Block ID], NULL AS [Photo],cls.[Valid From] As [Valid From]
			FROM [Integration].[EmployeePhoto_Staging] cls CROSS APPLY (
			  SELECT TOP ' +
			  CONVERT(nvarchar(3), @MaxRowCount) + ' ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS [Block ID]
				FROM sys.all_objects
			) a
		) b
		LEFT OUTER JOIN [Integration].[EmployeePhoto_Staging] cls
		  ON cls.[WWI Employee ID] = b.[WWI Employee ID]
		 AND cls.[Block ID] = b.[Block ID]
		 AND cls.[Valid From] = b.[Valid From]
	  ) x
	PIVOT
	(
	  max([Photo])
	  for [Block ID] in (' + @PivotColumns + ')
	) piv

	UPDATE [Integration].[Employee_Staging]
	SET [Integration].[Employee_Staging].[Photo] = EmployeePhotoHolder.[Photo]
	FROM EmployeePhotoHolder
	WHERE [Integration].[Employee_Staging].[WWI Employee ID] = EmployeePhotoHolder.[WWI Employee ID]
	and [Integration].[Employee_Staging].[Valid From] = EmployeePhotoHolder.[Valid From]

	DROP TABLE EmployeePhotoHolder
	'
	
	EXEC sp_executesql @Sql
END