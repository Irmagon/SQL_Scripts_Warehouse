-- Значение Преимущество индекса выше 5000 в промышленных системах означает, что следует рассмотреть возможность создания этих индексов.
-- Если же значение превышает 10000, это обычно означает, что индекс может обеспечить значительное повышение производительности для операций чтения.

SET NOCOUNT ON
DECLARE @dbid int
 
IF (object_id('tempdb..##IndexAdvantage') IS NOT NULL) DROP TABLE ##IndexAdvantage
CREATE TABLE ##IndexAdvantage (
[Преимущество индекса] int, 
[База данных] varchar(256),
[Число компиляций] int, 
[Количество операций поиска] int, 
[Средняя стоимость ] int, 
[Средний процент выигрыша] int, 
[Transact SQL код для создания индекса] varchar(1024));
 
DECLARE DBases CURSOR FOR
SELECT database_id FROM sys.master_files
WHERE state = 0 AND has_dbaccess(db_name(database_id)) = 1
GROUP BY database_id
 
OPEN DBases
FETCH NEXT FROM DBases
INTO @dbid
 
WHILE @@FETCH_STATUS = 0
BEGIN 
 
INSERT INTO ##IndexAdvantage
SELECT [Преимущество индекса] = CAST(user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)AS int),
      [База данных] = DB_NAME(mid.database_id),
      [Число компиляций] = CAST(migs.unique_compiles AS int),
      [Количество операций поиска] = CAST(migs.user_seeks AS int),
      [Средняя стоимость ] = CAST(migs.avg_total_user_cost AS int),
      [Средний процент выигрыша] = CAST(migs.avg_user_impact AS int),
      [Transact SQL код для создания индекса] = 'CREATE INDEX [IX_' + OBJECT_NAME(mid.object_id,@dbid) + '_' +
      CAST(mid.index_handle AS nvarchar) + '] ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns,'') +
      (CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ', ' ELSE '' END) +
      (CASE WHEN mid.inequality_columns IS NOT NULL THEN + mid.inequality_columns ELSE '' END) + ')' +
      (CASE WHEN mid.included_columns IS NOT NULL THEN ' INCLUDE (' + mid.included_columns + ')' ELSE '' END) + ';'
FROM  sys.dm_db_missing_index_groups mig
JOIN  sys.dm_db_missing_index_group_stats migs
ON    migs.group_handle = mig.index_group_handle
JOIN  sys.dm_db_missing_index_details mid
ON    mig.index_handle = mid.index_handle
AND   mid.database_id = @dbid
 
    FETCH NEXT FROM DBases
    INTO @dbid
END 
CLOSE DBases
DEALLOCATE DBases
GO
 
SELECT * FROM ##IndexAdvantage 
where [Преимущество индекса] >1000 and [База данных] <> 'msdb'
ORDER BY 2 ASC, 1 DESC

--Удаляем временную таблицу
IF (object_id('tempdb..##IndexAdvantage') IS NOT NULL) DROP TABLE ##IndexAdvantage
IF (object_id('tempdb..##IndexAdvantage2') IS NOT NULL) DROP TABLE ##IndexAdvantage2
