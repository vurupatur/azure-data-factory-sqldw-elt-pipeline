EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateExternalCityPopulationData'

PRINT 'Creating procedure [Integration].[MigrateExternalCityPopulationData]'
GO

CREATE PROCEDURE [Integration].[MigrateExternalCityPopulationData]
AS
BEGIN

	TRUNCATE TABLE [Integration].[CityPopulation_Staging]
	
	INSERT INTO [Integration].[CityPopulation_Staging]
	SELECT * FROM [External].[CityPopulation]


	DELETE FROM [Integration].[CityPopulation_Staging]
	WHERE RowNumber in (SELECT DISTINCT RowNumber
	FROM [Integration].[CityPopulation_Staging]
	WHERE POPULATION = 0
	GROUP BY RowNumber
	HAVING COUNT(RowNumber) = 4)
	

END