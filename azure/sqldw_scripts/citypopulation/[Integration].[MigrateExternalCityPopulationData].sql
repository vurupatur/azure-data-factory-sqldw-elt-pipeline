EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateExternalCityPopulationData'

PRINT 'Creating procedure [Integration].[MigrateExternalCityPopulationData]'
GO

CREATE PROCEDURE [Integration].[MigrateExternalCityPopulationData]
AS
BEGIN

	TRUNCATE TABLE [Integration].[CityPopulation_Staging]
	
	INSERT INTO [Integration].[CityPopulation_Staging]
	SELECT * FROM [External].[CityPopulation]

END