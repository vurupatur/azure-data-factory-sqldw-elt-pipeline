EXEC [dbo].[CreateTable] 'Fact', 'CityPopulation',
N'
	[WWI City ID] [int] NOT NULL,	
	[YearNumber] [int] NOT NULL,
	[Population] [int] NOT NULL,
	[City Key] int
',
'DISTRIBUTION = HASH ([YearNumber]),
CLUSTERED COLUMNSTORE INDEX'
