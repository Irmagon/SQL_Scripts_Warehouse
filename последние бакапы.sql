SELECT @@Servername AS ServerName
 , d.NAME AS DBName
 , b.Backup_finish_date
 , bmf.Physical_Device_name
FROM sys.databases d
INNER JOIN msdb..backupset b
 ON b.database_name = d.NAME
  AND b.[type] = 'D'
INNER JOIN msdb.dbo.backupmediafamily bmf
 ON b.media_set_id = bmf.media_set_id
ORDER BY b.Backup_finish_date DESC;
