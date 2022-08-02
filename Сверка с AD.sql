
DECLARE @Login1 VARCHAR(100)
       ,@IdDivision VARCHAR(255) = 1001
       ,@update INT = 1

IF OBJECT_ID(N'tempdb..#adsi', N'U') IS NOT NULL
  DROP TABLE #adsi

CREATE TABLE #adsi (
  A INT
 ,fio NVARCHAR(4000)
 ,Login1 NVARCHAR(4000)
 ,Surname NVARCHAR(4000)
 ,Firstname NVARCHAR(4000)
 ,Secondname NVARCHAR(4000)
 ,Rang NVARCHAR(4000)
 ,TelephoneWork NVARCHAR(4000)
 ,Mail NVARCHAR(4000)
 ,Department VARCHAR(255)
 ,City NVARCHAR(4000)
 ,Office NVARCHAR(4000)
)

DECLARE Cur INSENSITIVE CURSOR FOR SELECT DISTINCT
  [Last User]
FROM [_1]

FOR READ ONLY
OPEN Cur
FETCH NEXT FROM Cur INTO @Login1
WHILE @@fetch_status = 0
BEGIN
INSERT #adsi
EXEC master..[adsi] @Login1
FETCH NEXT FROM Cur INTO @Login1
END
DEALLOCATE Cur

SELECT DISTINCT
tu.*
,a.A

FROM [_1] tu
LEFT JOIN #adsi AS a ON tu.[Last User] = a.Login1


IF OBJECT_ID(N'tempdb..#adsi', N'U') IS NOT NULL
  DROP TABLE #adsi