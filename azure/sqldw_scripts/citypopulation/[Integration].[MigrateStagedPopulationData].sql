EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedPopulationData'

PRINT 'Creating procedure [Integration].[MigrateStagedPopulationData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedPopulationData]
AS
BEGIN
	
	TRUNCATE TABLE [Fact].[CityPopulation]


	CREATE TABLE CityHolder
	WITH (HEAP , DISTRIBUTION = HASH([WWI City ID]))
	AS

	SELECT c.[WWI City ID],c.[StateProvinceCode],c.[Valid From],c.[City],ROW_NUMBER() OVER (PARTITION BY c.[WWI City ID] ORDER BY c.[Valid From] DESC) as rn
	FROM [Dimension].[City] AS c


	
	INSERT INTO [Fact].[CityPopulation]
	SELECT
	cd.[WWI City ID],
	cps.[YearNumber], 
	cps.[Population]
	FROM [Integration].[CityPopulation_Staging] cps
	INNER JOIN CityHolder cd
	on cd.rn = 1
	and cps.[StateProvinceCode] = cd.[StateProvinceCode]
	and cps.CityName =  cd.City


	DROP TABLE CityHolder



END