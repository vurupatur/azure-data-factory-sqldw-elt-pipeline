EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateExternalCityPopulationData'

PRINT 'Creating procedure [Integration].[MigrateExternalCityPopulationData]'
GO

CREATE PROCEDURE [Integration].[MigrateExternalCityPopulationData]
AS
BEGIN
	IF OBJECT_ID('[Integration].[CityPopulation_Staging]') IS NOT NULL
	BEGIN
		TRUNCATE TABLE [Integration].[CityPopulation_Staging]
	END
	
	INSERT INTO [Integration].[CityPopulation_Staging]
	SELECT * FROM [External].[CityPopulation]
END