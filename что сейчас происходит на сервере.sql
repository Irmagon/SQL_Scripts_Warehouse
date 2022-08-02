SELECT session_id
     , Status
     , wait_type
     , command
     , last_wait_type
     , blocking_session_id
     , percent_complete
     , qt.text
     , total_elapsed_time 
     , wait_time  
     , (total_elapsed_time - wait_time) AS [work_time]
FROM sys.dm_exec_requests AS qs
  CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE session_id >= 50
  AND session_id <> @@SPID
ORDER BY total_elapsed_time DESC