SELECT  @@Servername AS Server ,
        DB_NAME() AS DBName ,
        isc.Table_Name AS TableName ,
        isc.Table_Schema AS SchemaName ,
        Ordinal_Position AS  Ord ,
        Column_Name ,
        Data_Type ,
        Numeric_Precision AS  Prec ,
--        Numeric_Scale AS  Scale ,
        Character_Maximum_Length AS LEN , -- -1 means MAX like Varchar(MAX) 
        isc.Is_Nullable ,
--        Column_Default ,
--        Table_Type  ,
--		id.column_id  ,
		Seed_Value as Ident,
		Last_Value
FROM     INFORMATION_SCHEMA.COLUMNS isc
        INNER JOIN  information_schema.tables ist
              ON isc.table_name = ist.table_name 
		left JOIN sys.identity_columns id on id.name=isc.COLUMN_NAME and isc.TABLE_NAME = OBJECT_NAME(object_id)
      WHERE Table_Type = 'BASE TABLE' -- 'Base Table' or 'View' 
ORDER BY DBName ,
        TableName ,
        SchemaName ,
        Ordinal_position;  
