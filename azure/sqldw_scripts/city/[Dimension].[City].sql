EXEC [dbo].[CreateTable] 'Dimension', 'City',
N'
  [WWI City ID] int,
  [City] nvarchar(50),
  [State Province] nvarchar(50),
  [Country] nvarchar(50),
  [Continent] nvarchar(30),
  [Sales Territory] nvarchar(50),
  [Region] nvarchar(30),
  [Subregion] nvarchar(30),
  [Latest Recorded Population] bigint,
  [Valid From] datetime2(7),
  [Valid To] datetime2(7) NULL,
  [Location] varbinary(max) NULL,
  [StateProvinceCode] nvarchar(10),
  [Lineage Key] int
',
'HEAP'
