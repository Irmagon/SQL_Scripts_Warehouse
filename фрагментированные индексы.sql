SELECT DISTINCT
  DatbaseName = DB_NAME(),
  TableName = OBJECT_NAME(s.[object_id]),
  IndexName = i.name,
  i.type_desc,
  s.alloc_unit_type_desc,
  [Fragmentation] = CAST(avg_fragmentation_in_percent*100 AS INT)/100, 
  page_count,
  partition_number,
   i.allow_row_locks,
   i.allow_page_locks,
  'alter index [' + i.name + '] on [' + sh.name + '].[' + OBJECT_NAME(s.[object_id]) + '] REBUILD'
  + CASE
    WHEN p.data_space_id IS NOT NULL
    THEN ' PARTITION = ' + CONVERT(VARCHAR(100), partition_number)
    ELSE ''
  END
  + ' with(maxdop = 0,  SORT_IN_TEMPDB = on, ONLINE = ON)'
  as [sql]

FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) s
INNER JOIN sys.indexes AS i ON
  s.[object_id] = i.[object_id]
  AND s.index_id = i.index_id
LEFT JOIN sys.partition_schemes AS p ON
  i.data_space_id = p.data_space_id
LEFT JOIN sys.objects o ON
  s.[object_id] = o.[object_id]
LEFT JOIN sys.schemas AS sh ON
  sh.[schema_id] = o.[schema_id]
WHERE
s.database_id = DB_ID()
AND i.name IS NOT NULL
AND OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
AND page_count > 100
AND avg_fragmentation_in_percent > 25
ORDER BY
2, Fragmentation