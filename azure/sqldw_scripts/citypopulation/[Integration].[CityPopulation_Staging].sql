EXEC [dbo].[CreateTable] 'Integration', 'CityPopulation_Staging',
N'
	[RowNumber] [int] NOT NULL,
	[StateProvinceCode] [nvarchar](3) NOT NULL,
	[CityName] [nvarchar](2000) NOT NULL,
	[YearNumber] [int] NOT NULL,
	[Population] [int] NOT NULL
',
'HEAP'
