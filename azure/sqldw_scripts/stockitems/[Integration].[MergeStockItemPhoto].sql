EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MergeStockItemPhoto'

PRINT 'Creating procedure [Integration].[MergeStockItemPhoto]'
GO

CREATE PROCEDURE [Integration].[MergeStockItemPhoto]
AS
BEGIN
  DECLARE @MaxRowCount int = (
	SELECT MAX(a.[RowCount])
	FROM (
			SELECT COUNT(*) AS [RowCount]
				FROM [Integration].[StockItemPhoto_Staging]
			GROUP BY [WWI Stock Item ID]
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
 

	DECLARE @Sql nvarchar(max) =
	N'
	CREATE TABLE StockItemPhotoHolder
	WITH (HEAP , DISTRIBUTION = HASH([WWI Stock Item ID]))
	AS

	SELECT [WWI Stock Item ID], CONVERT(varbinary(max), CONCAT(NULL, ' + @PivotColumns + ')) AS [Photo], [Valid From]
	  FROM (
		SELECT b.[WWI Stock Item ID], b.[Block ID], cls.[Photo],b.[Valid From]
		FROM (
		  SELECT DISTINCT cls.[WWI Stock Item ID], a.[Block ID], NULL AS [Photo],cls.[Valid From] As [Valid From]
			FROM [Integration].[StockItemPhoto_Staging] cls CROSS APPLY (
			  SELECT TOP ' +
			  CONVERT(nvarchar(3), @MaxRowCount) + ' ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS [Block ID]
				FROM sys.all_objects
			) a
		) b
		LEFT OUTER JOIN [Integration].[StockItemPhoto_Staging] cls
		  ON cls.[WWI Stock Item ID] = b.[WWI Stock Item ID]
		 AND cls.[Block ID] = b.[Block ID]
		 AND cls.[Valid From] = b.[Valid From]
	  ) x
	PIVOT
	(
	  max([Photo])
	  for [Block ID] in (' + @PivotColumns + ')
	) piv

	UPDATE [Integration].[StockItem_Staging]
	SET [Integration].[StockItem_Staging].[Photo] = StockItemPhotoHolder.[Photo]
	FROM StockItemPhotoHolder
	WHERE [Integration].[StockItem_Staging].[WWI Stock Item ID] = StockItemPhotoHolder.[WWI Stock Item ID]
	and [Integration].[StockItem_Staging].[Valid From] = StockItemPhotoHolder.[Valid From]

	DROP TABLE StockItemPhotoHolder
	'

	EXEC sp_executesql @Sql
END