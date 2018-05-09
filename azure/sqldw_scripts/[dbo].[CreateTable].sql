EXEC [dbo].[DropProcedureIfExists] 'dbo', 'CreateTable'

PRINT 'Creating procedure [dbo].[CreateTable]'
GO

CREATE PROCEDURE [dbo].[CreateTable]
(
  @SchemaName SYSNAME,
  @TableName SYSNAME,
  @ColumnDefinitions nvarchar(4000),
  @WithSettings nvarchar(4000)
)
AS
BEGIN
  DECLARE @FullName SYSNAME
  DECLARE @Sql nvarchar(2000)

  SET @FullName = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName)

  IF EXISTS (SELECT 1
    FROM sys.tables t
    INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
   WHERE t.[name] = @TableName
     AND s.[name] = @SchemaName)
  BEGIN
    PRINT 'Dropping table ' + @FullName
    SET @Sql = 'DROP TABLE ' + @FullName
    EXEC sp_executesql @Sql
  END

  PRINT 'Creating table ' + @FullName

  SET @Sql = 'CREATE TABLE ' + @FullName + '
(' + @ColumnDefinitions + ')'

  IF (@WithSettings IS NOT NULL)
  BEGIN
    SET @Sql = @Sql + '
WITH (' + @WithSettings + ')'
  END

  PRINT @Sql
  EXEC sp_executesql @Sql
END