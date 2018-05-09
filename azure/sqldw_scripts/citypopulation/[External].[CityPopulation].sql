DECLARE @DataSourceName sysname
DECLARE @ExternalFileFormatName sysname
SET @DataSourceName = 'CityPopulationDataSource'
SET @ExternalFileFormatName = 'CityPopulationFileFormat'
DECLARE @sql nvarchar(4000)

IF EXISTS (SELECT 1 FROM [sys].[external_tables] WHERE object_id = OBJECT_ID('[External].[CityPopulation]'))
BEGIN
  PRINT 'Dropping external table [External].[CityPopulation]'
  DROP EXTERNAL TABLE [External].[CityPopulation]
END

IF EXISTS (SELECT 1 FROM [sys].external_data_sources WHERE [name] = @DataSourceName)
BEGIN
  PRINT 'Dropping external data source ' + QUOTENAME(@DataSourceName)
  SET @sql = 'DROP EXTERNAL DATA SOURCE ' + QUOTENAME(@DataSourceName)
  EXEC sp_executesql @sql
END

IF EXISTS (SELECT 1 FROM [sys].[external_file_formats] WHERE [name] = @ExternalFileFormatName)
BEGIN
  PRINT 'Dropping external file format ' + QUOTENAME(@ExternalFileFormatName)
  SET @sql = N'DROP EXTERNAL FILE FORMAT ' + QUOTENAME(@ExternalFileFormatName)
  EXEC sp_executesql @sql
END

PRINT 'Creating external data source ' + QUOTENAME(@DataSourceName)
SET @sql = N'CREATE EXTERNAL DATA SOURCE ' + QUOTENAME(@DataSourceName) + '
WITH
(
  TYPE = Hadoop,
  LOCATION = ''wasbs://data@sqldwdatasets.blob.core.windows.net''
)'
EXEC sp_executesql @sql


PRINT 'Creating external file format ' + QUOTENAME(@ExternalFileFormatName)
SET @sql = 'CREATE EXTERNAL FILE FORMAT ' + QUOTENAME(@ExternalFileFormatName) + '
WITH (
  FORMAT_TYPE = DELIMITEDTEXT,
  FORMAT_OPTIONS (
      FIELD_TERMINATOR = '','',
      STRING_DELIMITER = '''',
      DATE_FORMAT = '''',
      USE_TYPE_DEFAULT = FALSE,
      FIRST_ROW = 2
  )
)'
EXEC sp_executesql @sql

PRINT 'Creating external table [External].[CityPopulation]'

SET @sql = 'CREATE EXTERNAL TABLE [External].[CityPopulation]
(
  [RowNumber] [int] NOT NULL,
  [StateProvinceCode] [nvarchar](3) NOT NULL,
  [CityName] [nvarchar](2000) NOT NULL,
  [YearNumber] [int] NOT NULL,
  [Population] [int] NOT NULL
)
WITH (
  DATA_SOURCE = ' + QUOTENAME(@DataSourceName) + ',
  LOCATION = N''/'',
  FILE_FORMAT = ' + QUOTENAME(@ExternalFileFormatName) + ',
  REJECT_TYPE = VALUE,
  REJECT_VALUE = 0
)'

EXEC sp_executesql @sql
