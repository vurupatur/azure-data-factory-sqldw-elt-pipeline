EXEC [dbo].[DropProcedureIfExists] 'Integration', 'MigrateStagedSaleData'

PRINT 'Creating procedure [Integration].[MigrateStagedSaleData]'
GO

CREATE PROCEDURE [Integration].[MigrateStagedSaleData] @SystemCutOffTime [datetime2](7) AS
BEGIN

  DECLARE @Lineage int
  DECLARE @DataLoadEndTime datetime2(7)

  SET @DataLoadEndTime = GETUTCDATE()

  SELECT TOP 1 @Lineage = LineageKey
  FROM [Integration].[Lineage]
  WHERE TableName = '[Fact].[Sale]'
  AND DataLoadEndTime IS NULL
  ORDER BY DataLoadStartTime DESC


	CREATE TABLE CityHolder
	WITH (HEAP , DISTRIBUTION = HASH([WWI Invoice ID]))
	AS
	SELECT DISTINCT s1.[WWI Invoice ID] AS [WWI Invoice ID],
	                c.[City Key] AS [City Key]
      FROM [Integration].[Sale_Staging] s1
     CROSS APPLY (
                   SELECT TOP 1 [City Key]
			         FROM [Dimension].[City]
				    WHERE [WWI City ID] = s1.[WWI City ID]
				      AND s1.[Last Modified When] > [Valid From]
	                  AND s1.[Last Modified When] <= [Valid To]
				    ORDER BY [Valid From], [City Key] DESC
 			     ) c

	UPDATE [Integration].[Sale_Staging]
	   SET [Integration].[Sale_Staging].[City Key] = CityHolder.[City Key]
	  FROM CityHolder
	 WHERE [Integration].[Sale_Staging].[WWI Invoice ID] = CityHolder.[WWI Invoice ID]

	DROP TABLE CityHolder

	CREATE TABLE CustomerHolder
	WITH (HEAP , DISTRIBUTION = HASH([WWI Customer ID]))
	AS

	SELECT c.[WWI Customer ID],c.[Valid From],s1.[WWI Invoice ID],ROW_NUMBER() OVER (PARTITION BY c.[WWI Customer ID],s1.[WWI Invoice ID] ORDER BY c.[Valid From] DESC) as rn
	FROM [Dimension].[Customer] AS c
	INNER JOIN [Integration].[Sale_Staging] s1
	ON c.[WWI Customer ID] = s1.[WWI Customer ID]
	AND s1.[Last Modified When] > c.[Valid From]
	AND s1.[Last Modified When] <= c.[Valid To]



	UPDATE [Integration].[Sale_Staging]
	SET [Integration].[Sale_Staging].[WWI Customer ID] =  CustomerHolder.[WWI Customer ID]
	FROM CustomerHolder
	WHERE CustomerHolder.rn = 1
	AND [Integration].[Sale_Staging].[WWI Invoice ID] = CustomerHolder.[WWI Invoice ID]
	AND [Integration].[Sale_Staging].[Last Modified When] >= CustomerHolder.[Valid From]

	DROP TABLE CustomerHolder


	CREATE TABLE BillToCustomerHolder
	WITH (HEAP , DISTRIBUTION = HASH([WWI Customer ID]))
	AS

	SELECT c.[WWI Customer ID],c.[Valid From],s1.[WWI Invoice ID],ROW_NUMBER() OVER (PARTITION BY c.[WWI Customer ID],s1.[WWI Invoice ID] ORDER BY c.[Valid From] DESC) as rn
	FROM [Dimension].[Customer] AS c
	INNER JOIN [Integration].[Sale_Staging] s1
	ON c.[WWI Customer ID] = s1.[WWI Bill To Customer ID]
	AND s1.[Last Modified When] > c.[Valid From]
	AND s1.[Last Modified When] <= c.[Valid To]



	UPDATE [Integration].[Sale_Staging]
	SET [Integration].[Sale_Staging].[WWI Bill To Customer ID] =  BillToCustomerHolder.[WWI Customer ID]
	FROM BillToCustomerHolder
	WHERE BillToCustomerHolder.rn = 1
	AND [Integration].[Sale_Staging].[WWI Invoice ID] = BillToCustomerHolder.[WWI Invoice ID]
	AND [Integration].[Sale_Staging].[Last Modified When] >= BillToCustomerHolder.[Valid From]

	DROP TABLE BillToCustomerHolder


	CREATE TABLE StockItemHolder
	WITH (HEAP , DISTRIBUTION = HASH([WWI Stock Item ID]))
	AS

	SELECT c.[WWI Stock Item ID],c.[Valid From],s1.[WWI Invoice ID],ROW_NUMBER() OVER (PARTITION BY c.[WWI Stock Item ID],s1.[WWI Invoice ID] ORDER BY c.[Valid From] DESC) as rn
	FROM [Dimension].[StockItem] AS c
	INNER JOIN [Integration].[Sale_Staging] s1
	ON c.[WWI Stock Item ID] = s1.[WWI Stock Item ID]
	AND s1.[Last Modified When] > c.[Valid From]
	AND s1.[Last Modified When] <= c.[Valid To]



	UPDATE [Integration].[Sale_Staging]
	SET [Integration].[Sale_Staging].[WWI Stock Item ID] =  StockItemHolder.[WWI Stock Item ID]
	FROM StockItemHolder
	WHERE StockItemHolder.rn = 1
	AND [Integration].[Sale_Staging].[WWI Invoice ID] = StockItemHolder.[WWI Invoice ID]
	AND [Integration].[Sale_Staging].[Last Modified When] >= StockItemHolder.[Valid From]

	DROP TABLE StockItemHolder


	
	CREATE TABLE EmployeeHolder
	WITH (HEAP , DISTRIBUTION = HASH([WWI Employee ID]))
	AS

	SELECT c.[WWI Employee ID],c.[Valid From],s1.[WWI Invoice ID],ROW_NUMBER() OVER (PARTITION BY c.[WWI Employee ID],s1.[WWI Invoice ID] ORDER BY c.[Valid From] DESC) as rn
	FROM [Dimension].[Employee] AS c
	INNER JOIN [Integration].[Sale_Staging] s1
	ON c.[WWI Employee ID] = s1.[WWI Saleperson ID]
	AND s1.[Last Modified When] > c.[Valid From]
	AND s1.[Last Modified When] <= c.[Valid To]



	UPDATE [Integration].[Sale_Staging]
	SET [Integration].[Sale_Staging].[WWI Saleperson ID] =  EmployeeHolder.[WWI Employee ID]
	FROM EmployeeHolder
	WHERE EmployeeHolder.rn = 1
	AND [Integration].[Sale_Staging].[WWI Invoice ID] = EmployeeHolder.[WWI Invoice ID]
	AND [Integration].[Sale_Staging].[Last Modified When] >= EmployeeHolder.[Valid From]

	DROP TABLE EmployeeHolder


  DELETE FROM [Fact].[Sale]
  WHERE [WWI Invoice ID] IN (SELECT [WWI Invoice ID] FROM [Integration].[Sale_Staging])

  INSERT INTO [Fact].[Sale] (
    [Invoice Date Key],
    [Delivery Date Key],
    [WWI Invoice ID],
    [Description],
    [Package],
    [Quantity],
    [Unit Price],
    [Tax Rate],
    [Total Excluding Tax],
    [Tax Amount],
    [Profit],
    [Total Including Tax],
    [Total Dry Items],
    [Total Chiller Items],
    [WWI City ID],
    [WWI Customer ID],
    [WWI Bill To Customer ID],
    [WWI Stock Item ID],
    [WWI Saleperson ID],
    [Last Modified When],
    [Lineage Key],
	[City Key]
  )
  SELECT 
  [Invoice Date Key],
  [Delivery Date Key],
  [WWI Invoice ID],
  [Description],
  [Package],
  [Quantity],
  [Unit Price],
  [Tax Rate],
  [Total Excluding Tax],
  [Tax Amount],
  [Profit],
  [Total Including Tax],
  [Total Dry Items],
  [Total Chiller Items],
  [WWI City ID],
  [WWI Customer ID],
  [WWI Bill To Customer ID],
  [WWI Stock Item ID],
  [WWI Saleperson ID],
  [Last Modified When],
  @Lineage,
  [City Key]
FROM [Integration].[Sale_Staging]

UPDATE [Integration].[Lineage]
SET DataLoadEndTime = @DataLoadEndTime
WHERE LineageKey = @Lineage

UPDATE [Integration].[ETLCutoff]
SET SystemCutoffTime = @SystemCutOffTime
WHERE TableName = '[Fact].[Sale]'

TRUNCATE TABLE [Integration].[Sale_Staging]

END