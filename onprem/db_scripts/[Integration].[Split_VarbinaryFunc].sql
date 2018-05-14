IF OBJECTPROPERTY (object_id('Integration.Split_VarbinaryFunc'), 'IsTableFunction') = 1
BEGIN
	DROP FUNCTION [Integration].[Split_VarbinaryFunc]
END
GO


CREATE FUNCTION [Integration].[Split_VarbinaryFunc](@vb VARBINARY(MAX))
RETURNS @t TABLE(block_id INT NOT NULL PRIMARY KEY,
                 start_index INT NOT NULL,
                 byte_count INT NOT NULL)
AS
BEGIN
  DECLARE @Blocks int
  SET @Blocks = DATALENGTH(@vb) / 8000
 
;WITH
E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
           SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
           SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
           SELECT 1),                 --10E1  or 10 rows
E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E2  or 100 rows
E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E3  or 10000 rows
E8(N) AS (SELECT 1 FROM E4 a, E4 b), --10E4  or 100000000 rows
E16(N) AS (SELECT 1 FROM E8 a, E8 b),  --10E16 or more rows than you can shake a stick at
BLOCK_RANGE AS (
  SELECT TOP (@Blocks + 1) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM E16
)
 
INSERT INTO @t(block_id, start_index, byte_count)
SELECT N, (8000 * (N - 1)) + 1 AS start_index,
       CASE
         WHEN N <= @Blocks THEN 8000
         ELSE DATALENGTH(@vb) % 8000
       END AS byte_count
FROM BLOCK_RANGE
RETURN
END
GO




