SELECT  @@ServerName AS Server ,
        DB_NAME() AS DBName ,
        OBJECT_NAME(ddps.object_id) AS TableName ,
        i.Type_Desc ,
        SUM(ddps.row_count) AS Rows
FROM    sys.dm_db_partition_stats AS ddps
        JOIN sys.indexes i ON i.object_id = ddps.object_id
                              AND i.index_id = ddps.index_id
WHERE   OBJECT_SCHEMA_NAME(ddps.object_id) <> 'sys'
GROUP BY ddps.object_id ,
        i.type_desc
ORDER BY TableName;
