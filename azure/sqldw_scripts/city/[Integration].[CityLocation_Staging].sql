EXEC [dbo].[CreateTable] 'Integration', 'CityLocation_Staging',
N'
  [WWI City ID] int,
  [Block ID] int,
  [Location] varbinary(8000),
  [Valid From] datetime2(7),
  [Valid To] datetime2(7) NULL
',
'HEAP'
