SELECT tbl.name,
       i.name,
       p.partition_number AS [PartitionNumber],
       p.data_compression_desc AS [DataCompression],
       p.rows  AS [RowCount]
  FROM sys.tables AS tbl
  LEFT JOIN sys.indexes AS i ON (i.index_id > 0 and i.is_hypothetical = 0) AND (i.object_id=tbl.object_id)
  INNER JOIN sys.partitions AS p ON p.object_id = CAST(tbl.object_id AS int) AND
                                    p.index_id = CAST(i.index_id AS int)
  where p.data_compression_desc <> 'PAGE' and
        p.rows >= 1000000
  order by p.rows desc, 3
