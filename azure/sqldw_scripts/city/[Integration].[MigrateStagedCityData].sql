EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedCityData'

PRINT 'Creating procedure [Integration].[MigrateStagedCityData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedCityData] @SystemCutOffTime [datetime2](7) AS
BEGIN

  DECLARE @Lineage int
  DECLARE @DataLoadEndTime datetime2(7)


  SET @DataLoadEndTime = GETUTCDATE()
  DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

  SELECT TOP 1 @Lineage = LineageKey
  FROM [Integration].[Lineage]
  WHERE TableName = '[Dimension].[City]'
  AND DataLoadEndTime IS NULL
  ORDER BY DataLoadStartTime DESC

  CREATE TABLE CityRowsToCloseOff
  WITH (
    DISTRIBUTION=ROUND_ROBIN,
    HEAP
  ) AS
  WITH RowsToCloseOff
  AS
  (
      SELECT c.[WWI City ID], MIN(c.[Valid From]) AS [Valid From]
      FROM [Integration].[City_Staging] AS c
      GROUP BY c.[WWI City ID]
  )
  SELECT * FROM RowsToCloseOff
  
 
  UPDATE [Dimension].[City]
  SET [Dimension].[City].[Valid To] = CityRowsToCloseOff.[Valid From]
  FROM CityRowsToCloseOff
  WHERE [CityRowsToCloseOff].[WWI City ID] = [Dimension].[City].[WWI City ID]
  AND [Dimension].[City].[Valid To] = @EndOfTime
 
  DROP TABLE CityRowsToCloseOff



  INSERT INTO [Dimension].[City](
    [WWI City ID],
    [City],
    [State Province],
    [Country],
    [Continent],
    [Sales Territory],
    [Region],
    [Subregion],
    [Latest Recorded Population],
    [Valid From],
    [Valid To],
    [Location],
    [StateProvinceCode],
    [Lineage Key]
  )
  SELECT 
    [WWI City ID],
    [City],
    [State Province],
    [Country],
    [Continent],
    [Sales Territory],
    [Region],
    [Subregion],
    [Latest Recorded Population],
    [Valid From],
    [Valid To],
    [Location],
    [StateProvinceCode],
    @Lineage
  FROM [Integration].[City_Staging]

  UPDATE [Integration].[Lineage]
  SET DataLoadEndTime = @DataLoadEndTime
  WHERE LineageKey = @Lineage

  UPDATE [Integration].[ETLCutoff]
  SET SystemCutoffTime = @SystemCutOffTime
  WHERE TableName = '[Dimension].[City]'

  TRUNCATE TABLE [Integration].[City_Staging]
  TRUNCATE TABLE [Integration].[CityLocation_Staging]


END