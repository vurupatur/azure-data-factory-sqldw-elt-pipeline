EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedPopulationData'

PRINT 'Creating procedure [Integration].[MigrateStagedPopulationData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedPopulationData]
AS
BEGIN
	IF OBJECT_ID('[Fact].[CityPopulation]') IS NOT NULL
	BEGIN
		TRUNCATE TABLE [Fact].[CityPopulation]
	END
	
	INSERT INTO [Fact].[CityPopulation]
	SELECT
	cd.[WWI City ID],
	cps.[YearNumber], 
	cps.[Population]
	FROM [Integration].[CityPopulation_Staging] cps
	INNER JOIN [Dimension].[City] cd
	on cps.[StateProvinceCode] = cd.[StateProvinceCode]
	and cps.CityName =  cd.City
END