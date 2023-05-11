

declare tables cursor for (select * from tblConfigTables);
declare @tableName nvarchar(max) = ''

open tables

fetch next from tables into @tableName
while @@fetch_status = 0
begin

	print @tableName

	declare @mapTableName nvarchar(max) = @tableName + 'Map'
	declare @sql nvarchar(max) = ''
	declare @count int = 0
	declare @schema nvarchar(max) = ''
	declare @mapColumn nvarchar(max) = ''
	declare @dataColumn nvarchar(max) = ''

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTablename, @tableName, @mapColumn out, @dataColumn out, @schema out

	--set @sql = formatmessage('delete from %s.%s where configurationid > 1', @schema, @mapTableName);
	--exec sys.sp_executesql @sql
	declare @subSelect nvarchar(max) = ''
	set @subSelect = formatmessage('select %d, %s, Previous%s, IsDeleted, ''%s'' from %s.%s where isDeleted = 0 and ConfigurationId = %d', @NewConfigurationID, @mapColumn, @mapColumn, @LastModifiedBy, @schema, @mapTableName, @ParentConfigurationId)
	set @sql = formatmessage('insert into %s.%s (ConfigurationID, %s, Previous%s, IsDeleted, LastModifiedBy) %s;', @schema, @mapTableName, @mapColumn, @mapColumn, @subSelect)

	exec sys.sp_executesql @sql

	fetch next from tables into @tableName
end

close tables
deallocate tables
go
