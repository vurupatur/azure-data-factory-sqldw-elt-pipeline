
EXEC [dbo].[CreateTable] 'Integration', 'EmployeePhoto_Staging',
N'

  [WWI Employee ID] int,
  [Block ID] int,
  [Photo] varbinary(8000),
  [Valid From] datetime2(7),
  [Valid To] datetime2(7) NULL
',
'HEAP'
