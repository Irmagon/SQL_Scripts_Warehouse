SELECT    @@SERVERNAME AS Server
          ,ss.name 
          ,ss.provider 
          ,Data_Source
          ,'Remote Login Name' = sl.remote_name 
          ,ss.modify_date 
      FROM sys.Servers ss 
 LEFT JOIN sys.linked_logins sl 
        ON ss.server_id = sl.server_id 
 order by ss.server_id
