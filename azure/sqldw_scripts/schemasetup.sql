DECLARE @SchemaName SYSNAME
DECLARE @Sql nvarchar(1000)

SET @SchemaName = N'Staging'
IF NOT EXISTS (SELECT 1 FROM [sys].[schemas] WHERE [name] = @SchemaName)
BEGIN
  PRINT 'Creating ' + @SchemaName + ' schema'
  SET @Sql = N'CREATE SCHEMA [' + @SchemaName + ']'
  EXEC sp_executesql @Sql
END
ELSE
BEGIN
  PRINT @SchemaName + ' schema already exists'
END

SET @SchemaName = N'Fact'
IF NOT EXISTS (SELECT 1 FROM [sys].[schemas] WHERE [name] = @SchemaName)
BEGIN
  PRINT 'Creating ' + @SchemaName + ' schema'
  SET @Sql = N'CREATE SCHEMA [' + @SchemaName + ']'
  EXEC sp_executesql @Sql
END
ELSE
BEGIN
  PRINT @SchemaName + ' schema already exists'
END

SET @SchemaName = N'Dimension'
IF NOT EXISTS (SELECT 1 FROM [sys].[schemas] WHERE [name] = @SchemaName)
BEGIN
  PRINT 'Creating ' + @SchemaName + ' schema'
  SET @Sql = N'CREATE SCHEMA [' + @SchemaName + ']'
  EXEC sp_executesql @Sql
END
ELSE
BEGIN
  PRINT @SchemaName + ' schema already exists'
END

SET @SchemaName = N'Integration'
IF NOT EXISTS (SELECT 1 FROM [sys].[schemas] WHERE [name] = @SchemaName)
BEGIN
  PRINT 'Creating ' + @SchemaName + ' schema'
  SET @Sql = N'CREATE SCHEMA [' + @SchemaName + ']'
  EXEC sp_executesql @Sql
END
ELSE
BEGIN
  PRINT @SchemaName + ' schema already exists'
END

SET @SchemaName = N'External'
IF NOT EXISTS (SELECT 1 FROM [sys].[schemas] WHERE [name] = @SchemaName)
BEGIN
  PRINT 'Creating ' + @SchemaName + ' schema'
  SET @Sql = N'CREATE SCHEMA [' + @SchemaName + ']'
  EXEC sp_executesql @Sql
END
ELSE
BEGIN
  PRINT @SchemaName + ' schema already exists'
END

