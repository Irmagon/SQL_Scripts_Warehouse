SELECT
  @@Servername AS Server
 ,DB_NAME() AS DBName

 ,o.name AS ObjectName
 ,dpr.authentication_type_desc AS authentication
 ,dpr.name AS Login
 ,dpr.modify_date
 ,(
  dp.state_desc + ' ' +
  dp.permission_name COLLATE Latin1_General_CS_AS +
  ' ON ' + '[' + s.name + ']' + '.' + '[' + o.name + ']' +
  ' TO ' + '[' + dpr.name + ']'
  ) AS GRANT_STMT
FROM sys.database_permissions AS dp
INNER JOIN sys.objects AS o
  ON dp.major_id = o.object_id
INNER JOIN sys.schemas AS s
  ON o.schema_id = s.schema_id
INNER JOIN sys.database_principals AS dpr
  ON dp.grantee_principal_id = dpr.principal_id
WHERE dpr.name NOT IN ('public', 'guest')
--  AND o.name IN ('My_Procedure')      -- Uncomment to filter to specific object(s)
--  AND dp.permission_name='EXECUTE'    -- Uncomment to filter to just the EXECUTEs
--ORDER BY dpr.name, o.name

UNION

SELECT
  @@Servername AS Server
 ,DB_NAME() AS DBName
 ,p.name AS ObjectName
 
,m.authentication_type_desc AS authentication
,m.name AS Login
,m.modify_date
,'' AS GRANT_STMT

FROM sys.database_role_members rm
JOIN sys.database_principals p
  ON rm.role_principal_id = p.principal_id
JOIN sys.database_principals m
  ON rm.member_principal_id = m.principal_id
WHERE m.name NOT LIKE 'dbo';