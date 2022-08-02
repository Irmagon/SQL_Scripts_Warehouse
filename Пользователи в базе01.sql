IF OBJECT_ID(N'tempdb..#tmpTable', N'U') IS NOT NULL DROP TABLE #tmpTable;

CREATE TABLE #tmpTable (
  Server NVARCHAR(128)
 ,DBName NVARCHAR(128)
 ,ObjectName NVARCHAR(128)
 ,authentication NVARCHAR(60)
 ,Login NVARCHAR(128)
 ,modify_date DATETIME
)

INSERT #tmpTable
EXEC sp_MSforeachdb 'use ?;
SELECT
  @@Servername AS Server
 ,DB_NAME() AS DBName
 ,o.name AS ObjectName
 ,dpr.type_desc AS authentication
 ,dpr.name AS Login
 ,dpr.modify_date
FROM sys.database_permissions AS dp
INNER JOIN sys.objects AS o ON dp.major_id = o.object_id
INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
INNER JOIN sys.database_principals AS dpr ON dp.grantee_principal_id = dpr.principal_id
WHERE dpr.name NOT IN (''public'', ''guest'')

UNION ALL

SELECT
  @@Servername AS Server
 ,DB_NAME() AS DBName
 ,p.name AS ObjectName
,m.type_desc AS authentication
,m.name AS Login
,m.modify_date
FROM sys.database_role_members rm
JOIN sys.database_principals p ON rm.role_principal_id = p.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE m.name NOT LIKE ''dbo'';'

SELECT *
FROM #tmpTable
WHERE DBName NOT IN ('msdb', 'master') AND authentication NOT IN ('DATABASE_ROLE')
ORDER BY DBName, ObjectName

IF OBJECT_ID(N'tempdb..#tmpTable', N'U') IS NOT NULL DROP TABLE #tmpTable;
