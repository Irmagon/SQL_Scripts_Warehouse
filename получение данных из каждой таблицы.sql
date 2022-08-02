CREATE TABLE #rowcount (Tablename VARCHAR(128), Rowcnt INT) 
EXEC sp_MSforeachtable 'insert into #rowcount select ''?'', count(*) from ?' 
SELECT  * FROM  #rowcount
ORDER BY Tablename, Rowcnt
DROP TABLE #rowcount