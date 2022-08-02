SELECT j.name as name
      ,[step_id] as step
      ,[step_name] as stepname
      ,[sql_message_id] as messageid
      ,[sql_severity] as severity
      ,[message] as message
      ,[run_status] as status
      ,convert(varchar,[run_date],104) as rundate
      ,substring (cast (1000000 + run_time as char (7)), 2, 2) +':'+ substring (cast (1000000 + run_time as char (7)), 4, 2)+':'+ substring (cast (1000000 + run_time as char (7)), 6, 2) as runtime
      ,substring (cast (1000000 + run_duration as char (7)), 2, 2) +':'+ substring (cast (1000000 + run_duration as char (7)), 4, 2)+':'+ substring (cast (1000000 + run_duration as char (7)), 6, 2) as duration
      ,[server] as server
  FROM [msdb].[dbo].[sysjobhistory] h
  join [msdb].[dbo].sysjobs j on h.job_id = j.job_id
  where 
run_date > '20220201'
and name not in ('syspolicy_purge_history','ExportHunterM')
and sql_severity IN (15,16) 
--and run_status in (0,2)
order by name asc, run_date asc
