SET QUOTED_IDENTIFIER ON;

DECLARE
@SQL VARCHAR(MAX),
@PageCount INT = 128,
@RebuildPercent INT = 30,
@ReorganizePercent INT = 20,
@IsOnlineRebuild BIT = 1,
@IsVersion2012Plus BIT =
CASE
  WHEN CAST(SERVERPROPERTY('productversion') AS CHAR(2)) NOT IN ('8.', '9.', '10')
  THEN 1
  ELSE 0
END,
@IsEntEdition BIT =
CASE
  WHEN SERVERPROPERTY('EditionID') IN (1804890536, -2117995310)
  THEN 1
  ELSE 0
END,
@SQL1 NVARCHAR(MAX)

SELECT
  @SQL1 =
  (
  SELECT
    '
    ALTER INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(s2.name) + '.' + QUOTENAME(o.name) + ' ' +
    CASE
      WHEN s.avg_fragmentation_in_percent >= @RebuildPercent
      THEN 'REBUILD'
      ELSE 'REORGANIZE'
    END + ' PARTITION = ' +
    CASE
      WHEN ds.[type] != 'PS'
      THEN 'ALL'
      ELSE CAST(s.partition_number AS NVARCHAR(10))
    END + ' WITH (' +
    CASE
      WHEN s.avg_fragmentation_in_percent >= @RebuildPercent
      THEN 'MAXDOP = 0, SORT_IN_TEMPDB = ON' +
        CASE
          WHEN @IsEntEdition = 1
            AND @IsOnlineRebuild = 1
            AND ISNULL(lob.is_lob_legacy, 0) = 0
            AND (
            ISNULL(lob.is_lob, 0) = 0
            OR
            (lob.is_lob = 1 AND @IsVersion2012Plus = 1)
            )
            AND i.allow_row_locks <> 0
            AND i.allow_page_locks <> 0
          THEN ', ONLINE = ON'
          ELSE ''
        END
      ELSE 'LOB_COMPACTION = ON'
    END + ')'
  FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) s
  JOIN sys.indexes i ON
    i.[object_id] = s.[object_id]
    AND i.index_id = s.index_id
  LEFT JOIN
  (
  SELECT
    c.[object_id],
    index_id = ISNULL(i.index_id, 1),
    is_lob_legacy = MAX(CASE
      WHEN c.system_type_id IN (34, 35, 99)
      THEN 1
    END),
    is_lob = MAX(CASE
      WHEN c.max_length = -1
      THEN 1
    END)
  FROM sys.columns c
  LEFT JOIN sys.index_columns i ON
    c.[object_id] = i.[object_id]
    AND c.column_id = i.column_id
    AND i.index_id > 0
  WHERE
  c.system_type_id IN (34, 35, 99)
  OR c.max_length = -1
  GROUP BY
  c.[object_id],
  i.index_id
  ) lob ON
    lob.[object_id] = i.[object_id]
    AND lob.index_id = i.index_id
  JOIN sys.objects o ON
    o.[object_id] = i.[object_id]
  JOIN sys.schemas s2 ON
    o.[schema_id] = s2.[schema_id]
  JOIN sys.data_spaces ds ON
    i.data_space_id = ds.data_space_id
  WHERE
  i.[type] IN (1, 2)
  AND i.is_disabled = 0
  AND i.is_hypothetical = 0
  AND s.index_level = 0
  AND s.page_count > @PageCount
  AND s.alloc_unit_type_desc = 'IN_ROW_DATA'
  AND o.[type] IN ('U', 'V')
  AND s.avg_fragmentation_in_percent > @ReorganizePercent
  FOR XML PATH (''), TYPE
  )
  .value('.', 'NVARCHAR(MAX)')

PRINT @SQL1

EXEC (@SQL1)