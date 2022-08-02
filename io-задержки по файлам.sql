-- Плохо: Ср.задержка одной операции > 20 мсек
USE master
GO

SELECT cast(db_name(a.database_id) AS VARCHAR) AS Database_Name
 , b.physical_name
 , a.io_stall
 , a.size_on_disk_bytes / 1024 / 1024 AS size_on_disk_Mb
 , a.io_stall_read_ms / a.num_of_reads 'Ср.задержка одной операции чтения'
 , a.io_stall_write_ms / a.num_of_writes 'Ср.задержка одной операции записи'
--, *
FROM sys.dm_io_virtual_file_stats(NULL, NULL) a
INNER JOIN sys.master_files b
 ON a.database_id = b.database_id
  AND a.file_id = b.file_id
WHERE num_of_writes > 0
 AND num_of_reads > 0
ORDER BY Database_Name
 , a.io_stall DESC
