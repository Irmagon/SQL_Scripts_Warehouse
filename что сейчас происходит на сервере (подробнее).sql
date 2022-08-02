select *
  from sys.sysprocesses where spid > 50 and spid <> @@spid and status <> 'sleeping'
  order by spid, ecid