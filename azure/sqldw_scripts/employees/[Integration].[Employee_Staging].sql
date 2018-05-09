
EXEC [dbo].[CreateTable] 'Integration', 'Employee_Staging',
N'
  [WWI Employee ID] int,
  [Employee] nvarchar(50),
  [Preferred Name] nvarchar(50),
  [Is Salesperson] bit,
  [Photo] varbinary NULL,
  [Valid From] datetime2(7),
  [Valid To] datetime2(7)
',
 'HEAP'