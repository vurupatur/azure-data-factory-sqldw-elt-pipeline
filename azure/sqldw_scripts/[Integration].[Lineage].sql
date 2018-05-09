EXEC [dbo].[CreateTable] 'Integration', 'Lineage',
N'
  [LineageKey] int NOT NULL IDENTITY(1,1) ,
  [TableName] varchar(30) NOT NULL,
  [DataLoadStartTime] datetime2(7) NOT NULL,
  [DataLoadEndTime] datetime2(7) NULL,
  [SystemCutoffTime] datetime2(7) NOT NULL
',
NULL