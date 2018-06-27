EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedPopulationData'

PRINT 'Creating procedure [Integration].[MigrateStagedPopulationData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedPopulationData]
AS
BEGIN
	
	TRUNCATE TABLE [Fact].[CityPopulation]

	INSERT INTO [Fact].[CityPopulation]
	SELECT     
		c.[WWI City ID] as [WWI City ID],
		cps.[YearNumber] as [YearNumber], 
		cps.[Population] as [Population],
		c.[City Key] as [City Key]
	FROM [Integration].[CityPopulation_Staging] cps
	CROSS APPLY (
					SELECT  TOP 1 cd.[City Key] ,cd.[WWI City ID]
					FROM [Dimension].[City] cd
					WHERE cps.[StateProvinceCode] = cd.[StateProvinceCode] 
					AND cps.[CityName] = cd.[City]
					AND   YEAR(cd.[Valid To]) >= cps.[YearNumber] 
					AND   YEAR(cd.[Valid From]) <= cps.[YearNumber]  
					ORDER BY [Valid From] ASC
				)c

END