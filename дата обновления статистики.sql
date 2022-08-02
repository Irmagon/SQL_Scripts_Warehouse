SELECT STATS_DATE(t1.object_id, stats_id), 'UPDATE STATISTICS [' + object_name(t1.object_id) + ']([' + t1.name + '])',
       i1.rows
  FROM sys.stats as t1
  inner join sys.sysobjects as t2 on t1.object_id = t2.id
  left join sysindexes as i1 on i1.id = t1.object_id and
                                i1.indid = 1
  where xtype = 'U' and
        STATS_DATE(t1.object_id, stats_id) < GETDATE()-5 and
        -- не учитываем: мусор, постоянные данные, таблицы на удаление
        t1.name not like 'disable%' and
        object_name(t1.object_id) not like '[__]%' and
        object_name(t1.object_id) not like 'T[_]%' and
        object_name(t1.object_id) not like 'OSMP%' and
        -- исключаем автостатистику,
        -- она создана по ad-hoc запросам, поэтому не является необходимой
        -- во время ночных расчетов
         t1.name not like '[_]WA[_]Sys[_]%'
  order by STATS_DATE(t1.object_id, stats_id)
