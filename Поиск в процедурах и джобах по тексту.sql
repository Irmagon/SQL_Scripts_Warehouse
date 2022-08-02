--Скрипт для поиска запросов v.2
--07.04.2016	Добавлен поиск в джобах
--use i_collect

DECLARE
@txt VARCHAR(4000) = '%CreditClientANR%'; --Здесь задаем ключевые слова для поиска нужного скрипта

--IF  object_id('tempdb..#query') is not null DROP TABLE #query

SELECT
  o.type_desc AS typ,
  o.name AS name,
  sm.definition AS query,
  DB_ID() AS id_db,
  DB_NAME() AS name_db,
  NULL AS last_execution,
  o.create_date,
  o.modify_date,
  1 AS id
--into #query
FROM sys.objects AS o
JOIN sys.sql_modules AS sm ON
  o.object_id = sm.object_id
WHERE
1 = 1
AND PATINDEX(@txt, sm.definition) > 0

UNION ALL

SELECT
  'Jobs' AS typ,
  'Job name: ' + j.name + ', Step: ' + CAST(js.step_id AS VARCHAR(10)) + ', Step name: ' + js.step_name AS name,
  js.command AS query,
  NULL AS id_db,
  js.database_name AS name_db,
  CAST(SUBSTRING(CAST(js.last_run_date AS VARCHAR(100)), 1, 4) + '-'
  + SUBSTRING(CAST(js.last_run_date AS VARCHAR(100)), 5, 2) + '-'
  + SUBSTRING(CAST(js.last_run_date AS VARCHAR(100)), 7, 2) + ' '
  + REVERSE(SUBSTRING(REVERSE(CAST(last_run_time AS VARCHAR(100))), 5, 2)) + ':'
  + REVERSE(SUBSTRING(REVERSE(CAST(last_run_time AS VARCHAR(100))), 3, 2)) + ':'
  + REVERSE(SUBSTRING(REVERSE(CAST(last_run_time AS VARCHAR(100))), 1, 2))
  AS DATETIME2(0)) AS last_execution,
  --CAST( js.last_run_date as varchar(100) ) + ' ' + CAST( last_run_time as varchar(100) ) as last_execution,
  j.date_created,
  j.date_modified,
  2 AS id
FROM msdb.dbo.sysjobsteps js
LEFT JOIN msdb.dbo.sysjobs j ON
  js.job_id = j.job_id
WHERE
1 = 1
AND PATINDEX(@txt, js.command) > 0

/*UNION ALL

SELECT
  'cached query plans',
  '',
  st.text,
  st.dbid,
  DB_NAME(st.dbid),
  qs.last_execution_time AS last_execution,
  qs.creation_time,
  NULL,
  3 AS id
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE
1 = 1
AND PATINDEX(@txt, st.text) > 0
AND st.text NOT LIKE '%Скрипт для поиска запросов%'
ORDER BY
id, o.type_desc, o.name, last_execution*/