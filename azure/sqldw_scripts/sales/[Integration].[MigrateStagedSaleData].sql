EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedSaleData'

PRINT 'Creating procedure [Integration].[MigrateStagedSaleData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedSaleData] @SystemCutOffTime [datetime2](7) AS
BEGIN

  DECLARE @Lineage int
  DECLARE @DataLoadEndTime datetime2(7)

  SET @DataLoadEndTime = GETUTCDATE()

  SELECT TOP 1 @Lineage = LineageKey
  FROM [Integration].[Lineage]
  WHERE TableName = '[Fact].[Sale]'
  AND DataLoadEndTime IS NULL
  ORDER BY DataLoadStartTime DESC

  UPDATE [Integration].[Sale_Staging]
  SET [WWI City ID] = COALESCE((SELECT TOP(1) c.[WWI City ID]
                                FROM [Dimension].[City] AS c
                                INNER JOIN [Integration].[Sale_Staging] s1
                                ON c.[WWI City ID] = s1.[WWI City ID]
                                AND s1.[Last Modified When] > c.[Valid From]
                                AND s1.[Last Modified When] <= c.[Valid To]
                                ORDER BY c.[Valid From]), 0)

  UPDATE [Integration].[Sale_Staging]
  SET [WWI Customer ID] = COALESCE((SELECT TOP(1) c.[WWI Customer ID]
                                    FROM [Dimension].[Customer] AS c
                                    INNER JOIN [Integration].Sale_Staging s1
                                    ON c.[WWI Customer ID] = s1.[WWI Customer ID]
                                    AND s1.[Last Modified When] > c.[Valid From]
                                    AND s1.[Last Modified When] <= c.[Valid To]
                                    ORDER BY c.[Valid From]), 0)

  UPDATE [Integration].[Sale_Staging]
  SET [WWI Bill To Customer ID] = COALESCE((SELECT TOP(1) c.[WWI Customer ID]
                                            FROM [Dimension].[Customer] AS c
                                            INNER JOIN [Integration].[Sale_Staging] s
                                            ON c.[WWI Customer ID] = s.[WWI Bill To Customer ID]
                                            AND s.[Last Modified When] > c.[Valid From]
                                            AND s.[Last Modified When] <= c.[Valid To]
                                            ORDER BY c.[Valid From]), 0)

  UPDATE [Integration].[Sale_Staging]
  SET [WWI Stock Item ID] = COALESCE((SELECT TOP(1) si.[WWI Stock Item ID]
                                      FROM [Dimension].[StockItem] AS si
                                      INNER JOIN [Integration].[Sale_Staging] s
                                      ON si.[WWI Stock Item ID] = s.[WWI Stock Item ID]
                                      AND s.[Last Modified When] > si.[Valid From]
                                      AND s.[Last Modified When] <= si.[Valid To]
                                      ORDER BY si.[Valid From]), 0)

  UPDATE [Integration].[Sale_Staging]
  SET [WWI Saleperson ID] = COALESCE((SELECT TOP(1) e.[WWI Employee ID]
                                      FROM [Dimension].[Employee] AS e
                                      INNER JOIN [Integration].[Sale_Staging] s
                                      ON e.[WWI Employee ID] = s.[WWI Saleperson ID]
                                      AND s.[Last Modified When] > e.[Valid From]
                                      AND s.[Last Modified When] <= e.[Valid To]
                                      ORDER BY e.[Valid From]), 0)

  DELETE FROM [Fact].[Sale]
  WHERE [WWI Invoice ID] IN (SELECT [WWI Invoice ID] FROM [Integration].[Sale_Staging])

  INSERT INTO [Fact].[Sale] (
    [Invoice Date Key],
    [Delivery Date Key],
    [WWI Invoice ID],
    [Description],
    [Package],
    [Quantity],
    [Unit Price],
    [Tax Rate],
    [Total Excluding Tax],
    [Tax Amount],
    [Profit],
    [Total Including Tax],
    [Total Dry Items],
    [Total Chiller Items],
    [WWI City ID],
    [WWI Customer ID],
    [WWI Bill To Customer ID],
    [WWI Stock Item ID],
    [WWI Saleperson ID],
    [Last Modified When],
    [Lineage Key]
  )
  SELECT
  [Invoice Date Key],
  [Delivery Date Key],
  [WWI Invoice ID],
  [Description],
  [Package],
  [Quantity],
  [Unit Price],
  [Tax Rate],
  [Total Excluding Tax],
  [Tax Amount],
  [Profit],
  [Total Including Tax],
  [Total Dry Items],
  [Total Chiller Items],
  [WWI City ID],
  [WWI Customer ID],
  [WWI Bill To Customer ID],
  [WWI Stock Item ID],
  [WWI Saleperson ID],
  [Last Modified When],
  @Lineage
FROM [Integration].[Sale_Staging]

UPDATE [Integration].[Lineage]
SET DataLoadEndTime = @DataLoadEndTime
WHERE LineageKey = @Lineage

UPDATE [Integration].[ETLCutoff]
SET SystemCutoffTime = @SystemCutOffTime
WHERE TableName = '[Fact].[Sale]'

TRUNCATE Table [Integration].[Sale_Staging]

END