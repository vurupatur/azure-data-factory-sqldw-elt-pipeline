EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedEmployeeData'

PRINT 'Creating procedure [Integration].[MigrateStagedEmployeeData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedEmployeeData]
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
  WHERE TableName = '[Dimension].[Employee]'
  AND DataLoadEndTime IS NULL
  ORDER BY DataLoadStartTime DESC

  CREATE TABLE EmployeeRowsToCloseOff
  WITH (
    DISTRIBUTION=ROUND_ROBIN,
    HEAP
  ) AS
  WITH RowsToCloseOff
  AS
  (
      SELECT c.[WWI Employee ID], MIN(c.[Valid From]) AS [Valid From]
      FROM [Integration].[Employee_Staging] AS c
      GROUP BY c.[WWI Employee ID]
  )
  SELECT * FROM RowsToCloseOff


  UPDATE [Dimension].[Employee]
  SET [Dimension].[Employee].[Valid To] = EmployeeRowsToCloseOff.[Valid From]
  FROM EmployeeRowsToCloseOff
  WHERE [EmployeeRowsToCloseOff].[WWI Employee ID] = [Dimension].[Employee].[WWI Employee ID]
  AND [Dimension].[Employee].[Valid To] = @EndOfTime

  DROP TABLE EmployeeRowsToCloseOff



  INSERT INTO [Dimension].[Employee]
  ( [WWI Employee ID],[Employee],[Preferred Name],[Is Salesperson],[Photo],[Valid From],[Valid To],[Lineage Key])
  SELECT [WWI Employee ID],[Employee],[Preferred Name],[Is Salesperson],[Photo],[Valid From],[Valid To] ,@Lineage
  FROM [Integration].[Employee_Staging]

  UPDATE [Integration].[Lineage]
  SET DataLoadEndTime = @DataLoadEndTime
  WHERE LineageKey = @Lineage

  UPDATE [Integration].[ETLCutoff]
  SET SystemCutoffTime = @SystemCutOffTime
  WHERE TableName = '[Dimension].[Employee]'

  TRUNCATE TABLE [Integration].[Employee_Staging]
  TRUNCATE TABLE [Integration].[EmployeePhoto_Staging]
END