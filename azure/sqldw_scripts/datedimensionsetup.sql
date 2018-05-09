DECLARE @StartDate datetime2(7) = DATEFROMPARTS(2010, 1, 1)
DECLARE @EndDate datetime2(7) = DATEFROMPARTS(2109, 12, 31)

IF EXISTS (SELECT 1
FROM sys.tables t
INNER JOIN sys.schemas s
ON t.schema_id = s.schema_id
WHERE t.[name] = 'Date'
	AND s.[name] = 'Dimension')
BEGIN
DROP TABLE [Dimension].[Date]
END



CREATE TABLE [Dimension].[Date]
WITH
(
  DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT [Date] AS [Date],                                                  -- 2013-01-01
       DATENAME(year, [Date]) +
           RIGHT(N'00' + CAST(DATEPART(month, [Date]) AS nvarchar), 2) +
           RIGHT(N'00' + DATENAME(day, [Date]), 2) AS [DateKey],          -- 20130101 (to 20131231)
       DATEPART(day, [Date]) AS [Day Number],                             -- 1 (to last day of month)
       DATENAME(day, [Date]) AS [Day],                                    -- 1 (to last day of month)
       DATENAME(dayofyear, [Date]) AS [Day of Year],                      -- 1 (to 365)
       DATEPART(dayofyear, [Date]) AS [Day of Year Number],               -- 1 (to 365)
       DATENAME(weekday, [Date]) AS [Day of Week],                        -- Tuesday
       DATEPART(weekday, [Date]) AS [Day of Week Number],                 -- 3
       DATENAME(week, [Date]) AS [Week of Year],                          -- 1
       DATENAME(month, [Date]) AS [Month],                                -- January
       LEFT(DATENAME(month, [Date]), 3) AS [Short Month],                 -- Jan
       N'Q' + DATENAME(quarter, [Date]) AS [Quarter],                     -- Q1 (to Q4)
       N'H' + CAST([Year Half] AS nvarchar) AS [Half of Year],            -- H1 (or H2)
       [Beginning of Month] AS [Beginning of Month],                      -- 2013-01-01
       [Beginning of Quarter] AS [Beginning of Quarter],                  -- 2013-01-01
       [Beginning of Half of Year] AS [Beginning of Half of Year],        -- 2013-01-01
       [Beginning of Year] AS [Beginning of Year],                        -- 2013-01-01
       N'Beginning of Month ' + DATENAME(month, [Date]) + '-' +
         DATENAME(year, [Date]) AS [Beginning of Month Label],
       N'BOM ' + LEFT(DATENAME(month, [Date]), 3) + '-' +
         DATENAME(year, [Date]) AS [Beginning of Month Label Short],
       N'Beginning Of Quarter ' + DATENAME(year, [Date]) + N'-Q' +
           DATENAME(quarter, [Date]) AS [Beginning of Quarter Label],
       N'BOQ ' + DATENAME(year, [Date]) + N'-Q' +
           DATENAME(quarter, [Date])
           AS [Beginning of Quarter Label Short],
       N'Beginning of Half Year ' + DATENAME(year, [Date]) + '-H' +
           CAST([Year Half] AS nvarchar)
           AS [Beginning of Half Year Label],                             -- Beginning of Half Year 2013-H1
       N'BOH ' + DATENAME(year, [Date]) + '-H' + CAST([Year Half] AS nvarchar)
           AS [Beginning of Half Year Label Short],                       -- BOH 2013-H1
       N'Beginning of Year ' + DATENAME(year, [Date])
           AS [Beginning of Year Label],                                  -- Beginning of Year 2013
       N'BOY ' + DATENAME(year, [Date]) AS [Beginning of Year Label Short],  -- BOY 2013
       DATENAME(month, [Date]) + ' ' + DATENAME(day, [Date]) +
           N', ' + DATENAME(year, [Date]) AS [Calendar Day Label],           -- January 1, 2013
       LEFT(DATENAME(month, [Date]), 3) + N' ' + DATENAME(day, [Date]) +
           N', ' + DATENAME(year, [Date]) AS [Calendar Day Label Short],     -- Jan 1, 2013
       DATEPART(week, [Date]) AS [Calendar Week Number],                     -- 1
       N'CY' + DATENAME(year, [Date]) + '-W' +
           RIGHT(N'00' + DATENAME(week, [Date]), 2)
           AS [Calendar Week Label],                                         -- CY2013-W1
       DATEPART(month, [Date]) AS [Calendar Month Number],                   -- 1 (to 12)
       N'CY' + DATENAME(year, [Date]) + '-' +
           LEFT(DATENAME(month, [Date]), 3) AS [Calendar Month Label],       -- CY2013-Jan
       LEFT(DATENAME(month, [Date]), 3) + N'-' + DATENAME(year, [Date])
           AS [Calendar Month Year Label],                                   -- Jan-2013
       DATEPART(quarter, [Date]) AS [Calendar Quarter Number],               -- 1 (to 4)
       N'CY' + DATENAME(year, [Date]) + N'-Q' + DATENAME(quarter, [Date])
           AS [Calendar Quarter Label],                                      -- CY2013-Q1
       N'Q' + DATENAME(quarter, [Date]) + '-' + DATENAME(year, [Date])
           AS [Calendar Quarter Year Label],                                 -- CY2013-Q1
       [Year Half] AS [Calendar Half of Year Number],                        -- 1 (to 2)
       'CY' + DATENAME(year, [Date]) + '-H' + CAST([Year Half] AS nvarchar)
           AS [Calendar Half of Year Label],                                 -- CY2013-H1
       N'H' + CAST([Year Half] AS nvarchar) + '-' + DATENAME(year, [Date])
           AS [Calendar Year Half of Year Label],                            -- H1-2013
       DATEPART(year, [Date]) AS [Calendar Year],                            -- 2013
       N'CY' + DATENAME(year, [Date]) AS [Calendar Year Label],              -- CY2013
       DATEPART(month, [Fiscal Date]) AS [Fiscal Month Number],              -- 7
       N'FY' + DATENAME(year, [Date]) + '-' +
           LEFT(DATENAME(month, [Date]), 3) AS [Fiscal Month Label],         -- FY2013-Jan
       DATEPART(quarter, [Fiscal Date]) AS [Fiscal Quarter Number],          -- 2
       N'FY' + DATENAME(year, [Date]) + '-Q' +
           DATENAME(quarter, [Fiscal Date]) AS [Fiscal Quarter Label],       -- FY2013-Q2
       [Fiscal Year Half] AS [Fiscal Half of Year Number],                   -- 1 (to 2)
       N'FY' + DATENAME(year, [Date]) + N'-H' +
           CAST([Fiscal Year Half] AS nvarchar)
           AS [Fiscal Half of Year Label],                                   -- FY2013-H2
       DATEPART(year, [Fiscal Date]) AS [Fiscal Year],                       -- 2013
       N'FY' + DATENAME(year, [Date]) AS [Fiscal Year Label],                -- FY2013
       CAST(DATENAME(year, [Date]) +
           RIGHT(N'00' + DATEPART(month, [Date]), 2) +
           RIGHT(N'00' + DATENAME(day, [Date]), 2) AS int) AS [Date Key],    -- 20130101 (to 20131231)
       CAST(DATENAME(year, [Date]) +
           RIGHT(N'00' + DATENAME(week, [Date]), 2) AS int)
           AS [Year Week Key],                                               -- 201301 (to 201353)
       CAST(DATENAME(year, [Date]) +
           RIGHT(N'00' + CAST(DATEPART(month, [Date]) AS nvarchar), 2) AS int)
           AS [Year Month Key],                                              -- 201301 (to 201312)
       CAST(DATENAME(year, [Date]) + DATENAME(quarter, [Date]) AS int)
           AS [Year Quarter Key],                                            -- 20131 (to 20134)
       CAST(DATENAME(year, [Date]) + CAST([Year Half] AS nvarchar) AS int)
           AS [Year Half of Year Key],                                       -- 20131 (to 20132)
       DATEPART(year, [Date]) AS [Year Key],                                 -- 2013
       CAST(DATENAME(year, [Date]) +
         RIGHT(N'00' + CAST(DATEPART(month, [Date]) AS nvarchar), 2) AS int)
           AS [Fiscal Year Month Key],                                       -- 201301 (to 201312)
       CAST(DATENAME(year, [Beginning of Month]) +
           RIGHT(N'00' +
             CAST(DATEPART(month, [Beginning of Month]) AS nvarchar), 2) +
           RIGHT(N'00' + DATENAME(day, [Beginning of Month]), 2) AS int)
           AS [Beginning of Month Key],                                      -- 20130101
       CAST(DATENAME(year, [Beginning of Quarter]) +
           RIGHT(N'00' +
             CAST(DATEPART(month, [Beginning of Quarter]) AS nvarchar), 2) +
           RIGHT(N'00' + DATENAME(day, [Beginning of Quarter]), 2) AS int)
           AS [Beginning of Quarter Key],                                    -- 20130101
       CAST(DATENAME(year, [Beginning of Half of Year]) +
           RIGHT(N'00' +
             CAST(DATEPART(month, [Beginning of Half of Year]) AS nvarchar), 2) +
           RIGHT(N'00' + DATENAME(day, [Beginning of Half of Year]), 2) AS int)
           AS [Beginning of Half of Year Key],                               -- 20130101
       CAST(DATENAME(year, [Beginning of Year]) +
           RIGHT(N'00' +
             CAST(DATEPART(month, [Beginning of Year]) AS nvarchar), 2) +
           RIGHT(N'00' + DATENAME(day, [Beginning of Year]), 2) AS int)
           AS [Beginning of Year Key],                                       -- 20130101
       CAST(DATENAME(year, [Fiscal Date]) +
           DATENAME(quarter, [Fiscal Date]) AS int)
           AS [Fiscal Year Quarter Key],                                     -- 20131
       CAST(DATENAME(year, [Fiscal Date]) +
           CAST([Fiscal Year Half] AS nvarchar) AS int)
           AS [Fiscal Year Half of Year Key],                                -- 20131
       DATEPART(ISO_WEEK, [Date]) AS [ISO Week Number]                       -- 1;
FROM (
    SELECT [Date],
           DATEADD(month, 6, [Date]) AS [Fiscal Date],
           CAST(DATEADD(month, DATEDIFF(month, 0, [Date]), 0) AS date)
               AS [Beginning of Month],
           DATEFROMPARTS(DATEPART(year, [Date]), 1, 1) AS [Beginning of Year],
           DATEFROMPARTS(DATEPART(year, [Date]), ((DATEPART(quarter, [Date]) - 1) * 3) + 1, 1)
               AS [Beginning of Quarter],
           DATEFROMPARTS(DATEPART(year, [Date]), ((DATEPART(month, [Date]) / 7) * 6) + 1, 1)
               AS [Beginning of Half of Year],
           (DATEPART(month, [Date]) / 7) + 1 AS [Year Half],
           (DATEPART(month, DATEADD(month, 6, [Date])) / 7) + 1 AS [Fiscal Year Half]
    FROM (
        SELECT TOP (DATEDIFF(day, @StartDate, @EndDate) + 1)
               DATEADD(day, ROW_NUMBER() OVER (ORDER BY s1.[object_id]) - 1, @StartDate) AS [Date]
        FROM sys.all_objects AS s1
        CROSS JOIN sys.all_objects AS s2
        ORDER BY s1.[object_id]
    ) AS gen_date
) AS gen_dates