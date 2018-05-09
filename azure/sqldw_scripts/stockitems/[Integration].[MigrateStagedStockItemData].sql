EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedStockItemData'

PRINT 'Creating procedure [Integration].[MigrateStagedStockItemData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedStockItemData]
(
  @SystemCutOffTime datetime2(7)
)
AS
BEGIN

  DECLARE @Lineage int
  DECLARE @DataLoadEndTime datetime2(7)

  SET @DataLoadEndTime = GETUTCDATE()

  DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

  SELECT TOP 1  @Lineage = LineageKey
  FROM [Integration].[Lineage]
  WHERE TableName = '[Dimension].[StockItem]'
  AND DataLoadEndTime IS NULL
  ORDER BY DataLoadStartTime DESC

  CREATE TABLE StockItemRowsToCloseOff
  WITH (
    DISTRIBUTION=ROUND_ROBIN,
    HEAP
  ) AS
  WITH RowsToCloseOff
  AS
  (
      SELECT c.[WWI Stock Item ID], MIN(c.[Valid From]) AS [Valid From]
      FROM [Integration].[StockItem_Staging] AS c
      GROUP BY c.[WWI Stock Item ID]
  )
  SELECT * FROM RowsToCloseOff


  UPDATE [Dimension].[StockItem]
  SET [Dimension].[StockItem].[Valid To] = StockItemRowsToCloseOff.[Valid From]
  FROM StockItemRowsToCloseOff
  WHERE [StockItemRowsToCloseOff].[WWI Stock Item ID] = [Dimension].[StockItem].[WWI Stock Item ID]
  AND [Dimension].[StockItem].[Valid To] = @EndOfTime

  DROP TABLE StockItemRowsToCloseOff


  INSERT INTO [Dimension].[StockItem]
  (
    [WWI Stock Item ID],
    [Stock Item],
    [Color],
    [Selling Package],
    [Buying Package],
    [Brand],
    [Size],
    [Lead Time Days],
    [Quantity Per Outer],
    [Is Chiller Stock],
    [Barcode],
    [Tax Rate],
    [Unit Price],
    [Recommended Retail Price],
    [Typical Weight Per Unit],
    [Photo],
    [Valid From],
    [Valid To],
    [Lineage Key]
)
SELECT
  [WWI Stock Item ID],
    [Stock Item],
    [Color],
    [Selling Package],
    [Buying Package],
    [Brand],
    [Size],
    [Lead Time Days],
    [Quantity Per Outer],
    [Is Chiller Stock],
    [Barcode],
    [Tax Rate],
    [Unit Price],
    [Recommended Retail Price],
    [Typical Weight Per Unit],
    [Photo],
    [Valid From],
    [Valid To],
    @Lineage
FROM [Integration].[StockItem_Staging]

UPDATE [Integration].[Lineage]
SET DataLoadEndTime = @DataLoadEndTime
WHERE LineageKey = @Lineage

UPDATE [Integration].[ETLCutoff]
SET SystemCutoffTime = @SystemCutOffTime
WHERE TableName = '[Dimension].[StockItem]'

TRUNCATE TABLE [Integration].[StockItem_Staging]
TRUNCATE TABLE [Integration].[StockItemPhoto_Staging]
END