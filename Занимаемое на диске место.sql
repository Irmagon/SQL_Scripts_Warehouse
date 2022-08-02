with spaceused as(
select
	a.FILEID,
	[FILE_SIZE_MB] = 
		convert(decimal(12,2),round(a.size/128.000,2)),
	[SPACE_USED_MB] =
		convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)),
	[FREE_SPACE_MB] =
		convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2)) ,
	NAME = left(a.NAME,128),
	FILENAME = left(a.FILENAME,520),
    FILE_GROUP = fg.name,
	STATE_DESC = df.state_desc,

	[DEFAULT] = fg.is_default 
from
	sys.sysfiles a
left join sys.database_files df on df.file_id = a.fileid
left join sys.filegroups as fg on fg.data_space_id =  df.data_space_id
) 
select 
	FILEID, 
	FILE_SIZE_MB,
	SPACE_USED_MB,
	FREE_SPACE_MB,
	[NAME],
	[FILENAME],
	FILE_GROUP,
	[STATE_DESC],
	[DEFAULT]
 from spaceused
union all
select	
	NULL as FILEID,
	sum(FILE_SIZE_MB)as FILE_SIZE_MB, 
	sum(SPACE_USED_MB)as SPACE_USED_MB,
	sum(FREE_SPACE_MB)as FREE_SPACE_MB,
	NULL as [NAME],
	NULL as [FILENAME],
	NULL as [STATE_DESC],
	NULL as FILE_GROUP,
	NULL as [DEFAULT]
from spaceused
