@ECHO OFF

REM Utility Stored Procedures
sqlcmd %* -b -i "[dbo].[DropProcedureIfExists].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "[dbo].[CreateTable].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM Schema setup
sqlcmd %* -b -i "schemasetup.sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM date dimension setup
sqlcmd %* -b -i "datedimensionsetup.sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM Lineage setup
sqlcmd %* -b -i "[Integration].[Lineage].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "[Integration].[CreateLineage].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "[Integration].[ETLCutoff].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM City setup
sqlcmd %* -b -i "city\[Dimension].[City].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "city\[Integration].[CityLocation_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "city\[Integration].[City_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "city\[Integration].[MergeLocation].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "city\[Integration].[MigrateStagedCityData].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM Customer setup
sqlcmd %* -b -i "customers\[Dimension].[Customer].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "customers\[Integration].[Customer_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "customers\[Integration].[MigrateStagedCustomerData].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM Employee setup
sqlcmd %* -b -i "employees\[Dimension].[Employee].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "employees\[Integration].[EmployeePhoto_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "employees\[Integration].[Employee_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "employees\[Integration].[MergeEmployeePhoto].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "employees\[Integration].[MigrateStagedEmployeeData].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM Stock Item setup
sqlcmd %* -b -i "stockitems\[Dimension].[StockItem].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "stockitems\[Integration].[StockItem_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "stockitems\[Integration].[StockItemPhoto_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "stockitems\[Integration].[MergeStockItemPhoto].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "stockitems\[Integration].[MigrateStagedStockItemData].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM Sale setup
sqlcmd %* -b -i "sales\[Fact].[Sale].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "sales\[Integration].[Sale_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "sales\[Integration].[MigrateStagedSaleData].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM City Population setup
sqlcmd %* -b -i "citypopulation\[External].[CityPopulation].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "citypopulation\[Integration].[CityPopulation_Staging].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "citypopulation\[Fact].[CityPopulation].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "citypopulation\[Integration].[MigrateExternalCityPopulationData].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "citypopulation\[Integration].[MigrateStagedEmployeeData].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1



REM Cleanup
ECHO Dropping procedure [dbo].[CreateTable]
sqlcmd %* -b -Q "DROP PROCEDURE [dbo].[CreateTable]"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

ECHO Dropping procedure [dbo].[DropProcedureIfExists]
sqlcmd %* -b -Q "DROP PROCEDURE [dbo].[DropProcedureIfExists]"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
