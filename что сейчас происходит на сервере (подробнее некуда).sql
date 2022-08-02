IF (OBJECT_ID('#sp_who2') IS NOT NULL)
  DROP TABLE #sp_who2
IF (OBJECT_ID('#sp_id_input') IS NOT NULL)
  DROP TABLE #sp_id_input
CREATE TABLE #sp_who2 (
  id INT IDENTITY (1, 1),
  SPID INT NULL,
  STATUS VARCHAR(1000) NULL,
  Login VARCHAR(1000) NULL,
  HostName VARCHAR(1000) NULL,
  BlkBy VARCHAR(1000) NULL,
  DbName VARCHAR(1000) NULL,
  Command VARCHAR(1000) NULL,
  CPUTime INT NULL,
  DISKIO INT,
  LasTBatch VARCHAR(1000) NULL,
  ProgramName VARCHAR(1000) NULL,
  SPID2 INT,
  REQUESTID INT
)
INSERT INTO #sp_who2
(
  SPID,
  STATUS,
  Login,
  HostName,
  BlkBy,
  DbName,
  Command,
  CPUTime,
  DISKIO,
  LasTBatch,
  ProgramName,
  SPID2,
  REQUESTID
)
EXEC sp_who2

DECLARE
  @sp_id INT
DECLARE
  @id INT
DECLARE
  @sql VARCHAR(8000)

CREATE TABLE #sp_id_input (
  EventType VARCHAR(255),
  [Parameters] VARCHAR(255),
  EventInfo TEXT,
  id INT NULL
)

    declare my_cursor cursor local for
        select id, SPID
        from #sp_who2
    for read only

    open my_cursor
FETCH NEXT FROM my_cursor
INTO @id, @sp_id

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @sql = 'DBCC INPUTBUFFER (' + CONVERT(VARCHAR(10), @sp_id) + ')'
  INSERT INTO #sp_id_input
  (
    EventType,
    [Parameters],
    EventInfo
  )
  EXEC (@sql)
  UPDATE #sp_id_input
    SET
      id = @id
  WHERE
    ISNULL(id, -1) = -1
  FETCH NEXT FROM my_cursor
  INTO @id, @sp_id
END
CLOSE my_cursor
DEALLOCATE my_cursor

SELECT
  SPID,
  STATUS,
  CASE
    WHEN
      (
        SELECT
          COUNT(*)
        FROM #sp_who2 sp_1
        WHERE
          sp_1.BlkBy = CONVERT(VARCHAR(10), sp.SPID)
      )
      > 0
      THEN 'blocking'
    WHEN LEN(RTRIM(LTRIM(REPLACE(BlkBy, '.', ' ')))) > 0
      THEN 'blocked'
    ELSE 'no'
  END AS BlockStatus,
  Login,
  HostName,
  REPLACE(BlkBy, '  .', '') AS BlkBy,
  DbName,
  Command,
  CPUTime,
  DISKIO,
  LasTBatch,
  ProgramName,
  EventType,
  ISNULL(EventInfo, '') AS EventInfo

FROM #sp_who2 sp
  LEFT JOIN #sp_id_input inp ON
        inp.id = sp.id
WHERE
  DbName NOT IN ('master', 'msdb', 'distribution', 'ReportServer')
  AND [Login] NOT IN ('sa', 'repl')
  AND ProgramName NOT IN ('Microsoft SQL Server Management Studio', 'EMS SQL Manager 2008 for SQL Server',
  'Microsoft SQL Server Management Studio - Query', 'MS SQL Maestro', 'dbForge Studio for SQL Server',
  'OSQL-32', 'Quest.RM4SP.CmdProcessor')
  AND sp.HostName NOT IN ('SEBSP','SEBDB2')
  AND EventInfo NOT LIKE '%ELECT 1'
  AND STATUS NOT LIKE 'sleeping'
DROP TABLE #sp_who2
DROP TABLE #sp_id_input