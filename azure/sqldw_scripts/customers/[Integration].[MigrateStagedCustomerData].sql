EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedCustomerData'

PRINT 'Creating procedure [Integration].[MigrateStagedCustomerData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedCustomerData] @SystemCutOffTime [datetime2](7) AS
BEGIN
  DECLARE @Lineage int
  DECLARE @DataLoadEndTime datetime2(7)

  SET @DataLoadEndTime = GETUTCDATE()
  DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

  SELECT TOP 1 @Lineage = LineageKey
  FROM [Integration].[Lineage]
  WHERE TableName = '[Dimension].[Customer]'
  AND DataLoadEndTime IS NULL
  ORDER BY DataLoadStartTime DESC

  CREATE TABLE CutomerRowsToCloseOff
  WITH (
    DISTRIBUTION=ROUND_ROBIN,
    HEAP
  ) AS
  WITH RowsToCloseOff
  AS
  (
      SELECT c.[WWI Customer ID], MIN(c.[Valid From]) AS [Valid From]
      FROM [Integration].[Customer_Staging] AS c
      GROUP BY c.[WWI Customer ID]
  )
  SELECT * FROM RowsToCloseOff


  UPDATE [Dimension].[Customer]
  SET [Dimension].[Customer].[Valid To] = CutomerRowsToCloseOff.[Valid From]
  FROM CutomerRowsToCloseOff
  WHERE [CutomerRowsToCloseOff].[WWI Customer ID] = [Dimension].[Customer].[WWI Customer ID]
  AND [Dimension].[Customer].[Valid To] = @EndOfTime

  DROP TABLE CutomerRowsToCloseOff

  INSERT INTO [Dimension].[Customer]
  ([WWI Customer ID],[Customer],[Bill To Customer],[Category],[Buying Group],[Primary Contact],[Postal Code],[Valid From],[Valid To],[Lineage Key])
  SELECT [WWI Customer ID],[Customer],[Bill To Customer],[Category],[Buying Group],[Primary Contact],[Postal Code],[Valid From],[Valid To],@Lineage
  FROM [Integration].[Customer_Staging]

  UPDATE [Integration].[Lineage]
  SET DataLoadEndTime = @DataLoadEndTime
  WHERE LineageKey = @Lineage

  UPDATE [Integration].[ETLCutoff]
  SET SystemCutoffTime = @SystemCutOffTime
  WHERE TableName = '[Dimension].[Customer]'

  TRUNCATE TABLE [Integration].[Customer_Staging]

END