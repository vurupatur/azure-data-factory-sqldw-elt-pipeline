IF EXISTS (SELECT 1
             FROM sys.procedures p
            INNER JOIN sys.schemas s
               ON p.[schema_id] = s.[schema_id]
            WHERE p.[name] = 'DropProcedureIfExists'
              AND s.[name] = 'dbo')
BEGIN
  PRINT 'Dropping procedure [dbo].[DropProcedureIfExists]'
  DROP PROCEDURE [dbo].[DropProcedureIfExists]
END
GO

PRINT 'Creating procedure [dbo].[DropProcedureIfExists]'
GO

CREATE PROCEDURE [dbo].[DropProcedureIfExists]
(
  @SchemaName SYSNAME,
  @ProcedureName SYSNAME
)
AS
BEGIN
  DECLARE @FullName SYSNAME
  DECLARE @Sql nvarchar(2000)
  SET @FullName = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ProcedureName)
  IF EXISTS (SELECT 1
               FROM sys.procedures p
              INNER JOIN sys.schemas s
                 ON p.[schema_id] = s.[schema_id]
              WHERE p.[name] = @ProcedureName
                AND s.[name] = @SchemaName)
  BEGIN
    PRINT 'Dropping procedure ' + @FullName
    SET @Sql = N'DROP PROCEDURE ' + @FullName
    EXEC sp_executesql @Sql
  END
END
