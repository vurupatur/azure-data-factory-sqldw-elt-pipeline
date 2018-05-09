EXEC [dbo].[CreateTable] 'Integration', 'ETLCutoff',
N'
  [TableName] varchar(30) not null,
  [SystemCutoffTime] datetime2(7) not null
',
NULL
