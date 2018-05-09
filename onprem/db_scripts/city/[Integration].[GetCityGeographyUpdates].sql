EXEC [dbo].[DropProcedureIfExists] 'Integration', 'GetCityGeographyUpdates'

PRINT 'Creating procedure [Integration].[GetCityGeographyUpdates]'
GO

CREATE PROCEDURE [Integration].[GetCityGeographyUpdates]
@LastCutoff datetime2(7),
@NewCutoff datetime2(7)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @EndOfTime datetime2(7) = '99991231 23:59:59.9999999';
    DECLARE @InitialLoadDate date = '20130101';

	CREATE TABLE #CityLocationChanges
	(
		 [WWI City ID] int,
		 [Block ID] int,
		 [Location] varbinary(8000),
		 [Valid From] datetime2(7),
         [Valid To] datetime2(7) NULL
	)

	DECLARE @CityID int;
    DECLARE @ValidFrom datetime2(7);
	DECLARE @Location varbinary(max);

	DECLARE CityChangeList CURSOR FAST_FORWARD READ_ONLY
    FOR
    SELECT c.CityID,
           c.ValidFrom,
			CAST(c.[Location] AS VARBINARY(MAX))
    FROM [Application].Cities_Archive AS c
    WHERE c.ValidFrom > @LastCutoff
    AND c.ValidFrom <= @NewCutoff
	AND c.[Location] is not null
    UNION ALL
    SELECT c.CityID,
           c.ValidFrom,
		  CAST(c.[Location] AS VARBINARY(MAX))
    FROM [Application].Cities AS c
    WHERE c.ValidFrom > @LastCutoff
    AND c.ValidFrom <= @NewCutoff
	AND c.[Location] is not null
    ORDER BY ValidFrom;

    OPEN CityChangeList;
    FETCH NEXT FROM CityChangeList INTO @CityID, @ValidFrom ,@Location;

    WHILE @@FETCH_STATUS = 0
    BEGIN

		INSERT #CityLocationChanges
			([WWI City ID],[Block ID],[Location],[Valid From],[Valid To])
		SELECT
			@CityID,
			block_id,
			CONVERT(VARBINARY(8000),substring(@Location,start_index,byte_count)),
			@ValidFrom,
			NULL
		FROM Integration.Split_VarbinaryFunc(@Location)

        FETCH NEXT FROM CityChangeList INTO @CityID, @ValidFrom,@Location;
    END;

    CLOSE CityChangeList;
    DEALLOCATE CityChangeList;

	CREATE INDEX IX_CityLocationChanges ON #CityLocationChanges ([WWI City ID], [Valid From]);

	UPDATE cc
    SET [Valid To] = COALESCE((SELECT MIN([Valid From]) FROM #CityLocationChanges AS cc2
                                                        WHERE cc2.[WWI City ID] = cc.[WWI City ID]
                                                        AND cc2.[Valid From] > cc.[Valid From]), @EndOfTime)
    FROM #CityLocationChanges AS cc;

	SELECT
		[WWI City ID] ,
		[Block ID] ,
		[Location] ,
		[Valid From] ,
		[Valid To]
	FROM #CityLocationChanges
	ORDER BY [Valid From]

	RETURN 0
END
