@ECHO OFF

REM Utility Stored Procedures
sqlcmd %* -b -i "[dbo].[DropProcedureIfExists].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

sqlcmd %* -b -i "[Integration].[Split_VarbinaryFunc].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "city\[Integration].[GetCityGeographyUpdates].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "city\[Integration].[GetCityUpdates].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "customers\[Integration].[GetCustomerUpdates].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "employees\[Integration].[GetEmployeePhotoUpdates].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "employees\[Integration].[GetEmployeeUpdates].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "sales\[Integration].[GetSaleUpdates].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "stockitems\[Integration].[GetStockItemPhotoUpdates].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "stockitems\[Integration].[GetStockItemUpdates].sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
sqlcmd %* -b -i "FixStateProvincesData.sql"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

REM Cleanup

ECHO Dropping procedure [dbo].[DropProcedureIfExists]
sqlcmd %* -b -Q "DROP PROCEDURE [dbo].[DropProcedureIfExists]"
IF %ERRORLEVEL% NEQ 0 EXIT /B 1