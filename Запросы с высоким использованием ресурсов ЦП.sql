SELECT TOP 10
  [Average CPU used] = total_worker_time / qs.execution_count
 ,[Total CPU used] = total_worker_time
 ,[Execution count] = qs.execution_count
 ,[Parent Query] = qt.text
 ,qs.creation_time
 ,qs.total_physical_reads
 ,qs.total_logical_reads
 ,qs.total_elapsed_time / 1000 AS total_elapsed_time
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE qs.execution_count =1 AND qs.creation_time > dateadd(MINUTE,-15,getdate())
AND qs.total_elapsed_time / 1000 > 1000
ORDER BY [Average CPU used] DESC;
