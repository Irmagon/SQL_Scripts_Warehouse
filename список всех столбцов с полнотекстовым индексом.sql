SELECT
 @@Servername AS Server
,DB_NAME() AS DBName
,isc.Table_Name AS TableName
,Column_Name
,Data_Type
,Character_Maximum_Length AS LEN
,t0.name AS Fulltext
FROM INFORMATION_SCHEMA.COLUMNS isc
INNER JOIN information_schema.tables ist ON isc.table_name = ist.table_name
LEFT JOIN sys.identity_columns id ON id.name = isc.COLUMN_NAME AND isc.TABLE_NAME = OBJECT_NAME(object_id)
LEFT JOIN (SELECT DISTINCT OBJECT_NAME(fic.[object_id]) AS table_name,[name]
            FROM sys.fulltext_index_columns fic
            INNER JOIN sys.columns c ON c.[object_id] = fic.[object_id] AND c.[column_id] = fic.[column_id]) AS t0 ON isc.TABLE_NAME = t0.table_name AND isc.COLUMN_NAME = t0.name
WHERE Table_Type = 'BASE TABLE' -- 'Base Table' or 'View' 
AND isc.COLUMN_NAME IN ('Comment', 'DataFile')
ORDER BY DBName,
TableName,
Ordinal_position;  
