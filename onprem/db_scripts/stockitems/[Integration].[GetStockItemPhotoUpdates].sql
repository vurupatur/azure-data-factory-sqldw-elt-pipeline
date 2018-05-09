EXEC [dbo].[DropProcedureIfExists] 'Integration', 'GetStockItemPhotoUpdates'

PRINT 'Creating procedure [Integration].[GetStockItemPhotoUpdates]'
GO

CREATE PROCEDURE [Integration].[GetStockItemPhotoUpdates]
@LastCutoff datetime2(7),
@NewCutoff datetime2(7)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) = '99991231 23:59:59.9999999';

    CREATE TABLE #StockItemPhotoChanges
    (
        [WWI Stock Item ID] int,
		[Block ID] int,
        [Photo] varbinary(8000),
        [Valid From] datetime2(7),
        [Valid To] datetime2(7)null
    );

    DECLARE @StockItemID int;
    DECLARE @ValidFrom datetime2(7);
	DECLARE @Photo varbinary(max)

    -- need to find any StockItem changes that have occurred, including during the initial load

    DECLARE StockItemPhotoChangeList CURSOR FAST_FORWARD READ_ONLY
    FOR
    SELECT c.StockItemID,
           c.ValidFrom,
		   CAST(c.Photo as varbinary(max))
    FROM Warehouse.StockItems_Archive AS c
    WHERE c.ValidFrom > @LastCutoff
    AND c.ValidFrom <= @NewCutoff
	AND c.Photo is not null
    UNION ALL
    SELECT c.StockItemID,
           c.ValidFrom,
		   CAST(c.Photo as varbinary(max))
    FROM Warehouse.StockItems AS c
    WHERE c.ValidFrom > @LastCutoff
    AND c.ValidFrom <= @NewCutoff
	AND c.Photo is not null
    ORDER BY ValidFrom;

    OPEN StockItemPhotoChangeList;
    FETCH NEXT FROM StockItemPhotoChangeList INTO @StockItemID, @ValidFrom,@Photo;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT #StockItemPhotoChanges(
			[WWI Stock Item ID],
			[Block ID],
			[Photo],
			[Valid From],
			[Valid To])
        SELECT
			@StockItemID,
			block_id,
			CONVERT(VARBINARY(8000),substring(@Photo,start_index,byte_count)),
			@ValidFrom,
			NULL
		FROM Integration.Split_VarbinaryFunc(@Photo)

        FETCH NEXT FROM StockItemPhotoChangeList INTO @StockItemID, @ValidFrom,@Photo;
    END;

    CLOSE StockItemPhotoChangeList;
    DEALLOCATE StockItemPhotoChangeList;

    -- add an index to make lookups faster

    CREATE INDEX IX_StockItemPhotoChanges ON #StockItemPhotoChanges ([WWI Stock Item ID], [Valid From]);

    -- work out the [Valid To] value by taking the [Valid From] of any row that's for the same StockItem but later
    -- otherwise take the end of time

    UPDATE cc
    SET [Valid To] = COALESCE((SELECT MIN([Valid From]) FROM #StockItemPhotoChanges AS cc2
                                                        WHERE cc2.[WWI Stock Item ID] = cc.[WWI Stock Item ID]
                                                        AND cc2.[Valid From] > cc.[Valid From]), @EndOfTime)
    FROM #StockItemPhotoChanges AS cc;

    SELECT [WWI Stock Item ID],
		   [Block ID]
           [Photo],
		   [Valid From], [Valid To]
    FROM #StockItemPhotoChanges
    ORDER BY [Valid From];

    DROP TABLE #StockItemPhotoChanges;

    RETURN 0;
END;
