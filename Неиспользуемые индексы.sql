SELECT DatabaseName = DB_NAME()
 , TableName = OBJECT_NAME(s.[object_id])
 , IndexName = i.NAME
 , user_updates
 , system_updates
 , 'EXEC sp_rename ''[dbo].[' + OBJECT_NAME(s.[object_id]) + '].[' + i.NAME + ']'',''disable_' + i.NAME + ''',''INDEX''' AS Rename
 , 'ALTER INDEX ' + i.NAME + ' ON ' + OBJECT_NAME(s.[object_id]) + ' DISABLE' AS [Disable]
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i
 ON s.[object_id] = i.[object_id]
  AND s.index_id = i.index_id
WHERE s.database_id = DB_ID()
 AND OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
 AND user_seeks = 0
 AND user_scans = 0
 AND user_lookups = 0
 AND i.is_disabled <> 1
 AND i.is_primary_key <> 1
ORDER BY user_updates + system_updates DESC
