EXEC [dbo].[CreateTable] 'Dimension', 'Customer',
N'
  [WWI Customer ID] int,
  [Customer] nvarchar(100),
  [Bill To Customer] nvarchar(100),
  [Category] nvarchar(50),
  [Buying Group] nvarchar(50),
  [Primary Contact] nvarchar(50),
  [Postal Code] nvarchar(10),
  [Valid From] datetime2(7),
  [Valid To] datetime2(7) NULL,
  [Lineage Key] int
',
'HEAP'
