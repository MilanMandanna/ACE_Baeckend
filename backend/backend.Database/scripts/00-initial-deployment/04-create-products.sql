
declare @globalDefinitionId int = 1
declare @globalConfigurationId int = (select max(configurationid) from tblconfigurations where configurationdefinitionid = @globalDefinitionId);

-- create the global configuration definition
insert into dbo.tblConfigurationDefinitions 
	(ConfigurationDefinitionID, ConfigurationDefinitionParentID, ConfigurationTypeID, OutputTypeID, Active, AutoLock, AutoDeploy, AutoMerge, FeatureSetID) values
	(1, 0, 1, 8, 1, 1, 1, 1, 1);

-- create the global configuration version
insert into dbo.tblConfigurations 
	(ConfigurationID, ConfigurationDefinitionID, Version, Locked, Description) VALUES
	(1, 1, 1, 0, 'Global Configuration');

-- create the global configuration mapping
insert into dbo.tblGlobals (GlobalID, Name, Description) values (1, 'Global', 'Global configuration');
declare @globalId int = (select max(globalid) from dbo.tblglobals)
insert into dbo.tblGlobalConfigurationMapping (GlobalConfigurationMappingID, GlobalID, ConfigurationDefinitionID, MappingIndex) values (1, @globalId, @globalDefinitionId, 0);

--
-- populate all the mappin tables for the global configuration
--
declare @configurationId int = 1;

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

	set @sql = formatmessage('set @count = (select count(*) from %s.%s where configurationid = %d);', @schema, @mapTableName, @configurationId);
	print @sql
	exec sys.sp_executesql @sql, N'@count int out', @count = @count out
	print @count

	if @count = 0
	begin
		set @sql = formatmessage('insert into %s.%s (%s, Previous%s, ConfigurationId, IsDeleted, Action) select %s, NULL, %d, 0, ''Initial Import'' from %s.%s', @schema, @mapTableName, @mapColumn, @mapColumn, @dataColumn, @configurationId, @schema, @tableName)
		print @sql
		exec sys.sp_executesql @sql
	end

	fetch next from tables into @tableName
end

close tables
deallocate tables
go

-- create the configuration definitions

-- ceshtse
insert into dbo.tblConfigurationDefinitions
	(configurationdefinitionid, configurationdefinitionparentid, configurationtypeid, outputtypeid, active, autolock, autodeploy, automerge, featuresetid) values
	(2, 1, 5, 3, 1, 1, 1, 1, 1);

-- pac3d
insert into dbo.tblConfigurationDefinitions
	(configurationdefinitionid, configurationdefinitionparentid, configurationtypeid, outputtypeid, active, autolock, autodeploy, automerge, featuresetid) values
	(3, 1, 2, 5, 1, 1, 1, 1, 1);

-- thales2d
insert into dbo.tblConfigurationDefinitions
	(configurationdefinitionid, configurationdefinitionparentid, configurationtypeid, outputtypeid, active, autolock, autodeploy, automerge, featuresetid) values
	(4, 1, 6, 4, 1, 1, 1, 1, 1);

-- as4xxx
insert into dbo.tblConfigurationDefinitions
	(configurationdefinitionid, configurationdefinitionparentid, configurationtypeid, outputtypeid, active, autolock, autodeploy, automerge, featuresetid) values
	(5, 1, 3, 1, 1, 1, 1, 1, 1);
go

-- create products
insert into dbo.tblproducts
	(productid, [name], [description]) values
	(1, 'AS4XXX', 'AS4XXX Product Configuration');
insert into dbo.tblproducts
	(productid, [name], [description]) values
	(2, 'ASXi-3', 'ASXi-3 Product Configuration');
insert into dbo.tblproducts
	(productid, [name], [description]) values
	(3, 'PAC2D/Thales2D', 'PAC 2D/Thales 2D Product Configuration');
insert into dbo.tblproducts
	(productid, [name], [description]) values
	(4, 'ASXi-4/5', 'ASXi-4/5 Product Configuration');

-- create product mappings
insert into dbo.tblproductconfigurationmapping
	(productid, configurationdefinitionid) values
	(1, 5);
insert into dbo.tblproductconfigurationmapping
	(productid, configurationdefinitionid) values
	(2, 2);
insert into dbo.tblproductconfigurationmapping
	(productid, configurationdefinitionid) values
	(3, 4);
insert into dbo.tblproductconfigurationmapping
	(productid, configurationdefinitionid) values
	(4, 3);

-- branch the global configuration to the individual products
exec dbo.SP_CreateBranch 1, 5, 'Initial Setup', 'AS4XXX Product Configuration'
exec dbo.SP_CreateBranch 1, 2, 'Initial Setup', 'CESHTSE Product Configuration'
exec dbo.SP_CreateBranch 1, 4, 'Initial Setup', 'Thales2D Product Configuration'
exec dbo.SP_CreateBranch 1, 3, 'Initial Setup', 'PAC3D Product Configuration'

