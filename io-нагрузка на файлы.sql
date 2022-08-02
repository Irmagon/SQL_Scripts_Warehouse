SELECT DB_NAME(saf.dbid) AS [База данных]
 , saf.NAME AS [Логическое имя]
 , vfs.NumberReads AS [Операций чтений]
 , vfs.IoStallReadMS / 1000 AS [Ожидание чтения (С)]
 , vfs.BytesRead / 1048576 AS [Прочитано (Мб)]
 , vfs.NumberWrites AS [Операций записи]
 , vfs.IoStallWriteMS / 1000 AS [Ожидание записи (С)]
 , vfs.BytesWritten / 1048576 AS [Записано (Мб)]
 , vfs.BytesOnDisk / 1048576 AS [Размер (Мб)]
 , saf.filename AS [Путь к файлу]
FROM master..sysaltfiles AS saf
INNER JOIN::fn_virtualfilestats(NULL, NULL) AS vfs
 ON vfs.dbid = saf.dbid
  AND vfs.fileid = saf.fileid
  AND saf.dbid NOT IN (
   1
   , 3
   , 4
   )
ORDER BY 1 ASC
 , 2 ASC
