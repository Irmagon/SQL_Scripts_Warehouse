SELECT  @@SERVERNAME AS Server ,
        d.name AS DBName ,
        create_date ,
        compatibility_level ,
        d.state_desc,
        d.recovery_model_Desc AS RecoveryModel,
        m.physical_name AS FileName
FROM    sys.databases d
        JOIN sys.master_files m ON d.database_id = m.database_id
WHERE   m.[type] = 0 -- data files only
ORDER BY d.name;