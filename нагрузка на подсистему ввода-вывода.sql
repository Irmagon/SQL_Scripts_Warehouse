SELECT TOP 10 (total_logical_reads / execution_count) AS avg_logical_reads
 , (total_logical_writes / execution_count) AS avg_logical_writes
 , (total_physical_reads / execution_count) AS avg_phys_reads
 , Execution_count
 , statement_start_offset AS stmt_start_offset
 ,
 --    plan_handle,
 qt.TEXT
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY (total_logical_reads + total_logical_writes) DESC
