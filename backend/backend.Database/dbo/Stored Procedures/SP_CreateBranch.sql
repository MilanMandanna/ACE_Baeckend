SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Updated By:		Prajna Hegde
-- Update date: 02/02/2022
-- Description:	Added tblASXiInsetMap and tblMapInsetsMap to the list of Configurable Tables. 
				-- Also added DROP PROC block so that it overwrites the existing procedure
-- EXEC [dbo].[SP_CreateBranch] 107,5066,''
-- =============================================

IF OBJECT_ID('[dbo].[SP_CreateBranch]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateBranch]
END
GO

CREATE PROCEDURE [dbo].[SP_CreateBranch] 
	-- Add the parameters for the stored procedure here
	@FromConfigurationID int,
	@IntoConfigurationDefinitionID int,
	@LastModifiedBy nvarchar(100),
	@Description nvarchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from 
	-- interfering with SELECT statements.
	BEGIN TRY
		BEGIN TRANSACTION CreateConfiguration
		SET NOCOUNT ON;

		 -- report an error if we are create a new version for the same configuration definition and the version we are branching from is not locked

		 declare @fromConfigurationDefinitionId int = (select configurationdefinitionid from tblconfigurations where configurationid = @FromConfigurationID)
		 if (select count(1) from tblconfigurations where configurationdefinitionid = @fromConfigurationDefinitionId ) =1		
		 begin
			 set @FromConfigurationID  =(select max(configurationid) from tblconfigurations where configurationdefinitionid IN
			 (select ConfigurationDefinitionParentID from tblConfigurationDefinitions where configurationdefinitionid = @fromConfigurationDefinitionId) and locked = 1)
		 end
		


		declare @version as int = (select max(version) + 1 from tblconfigurations where configurationdefinitionid = @intoconfigurationdefinitionid);
		if @version is null begin set @version = 1 end

		-- get the next configuration id
		declare @NewConfigurationID as int = (Select max(ConfigurationID) + 1 from  [dbo].[tblConfigurations]);

		-- Create a new configuration
		insert into [dbo].[tblConfigurations]
			([ConfigurationID], [ConfigurationDefinitionID], [Version], [Locked], Description) values
			(@NewConfigurationID, @IntoConfigurationDefinitionID, @version, 0, @Description);

		declare @ParentConfigurationID as int = null
		--set @parentconfigurationid = null
		if exists (select max(configurationid) from tblconfigurations where configurationdefinitionid = @IntoConfigurationDefinitionID)
		begin
			set @ParentConfigurationID = (select max(configurationid) from tblconfigurations where configurationdefinitionid = @IntoConfigurationDefinitionID);
		end

		declare tables cursor for (select tblName from tblConfigTables);
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
			set @subSelect = formatmessage('select %d, %s, Previous%s, IsDeleted, ''%s'' from %s.%s where isDeleted = 0 and ConfigurationId = %d', @NewConfigurationID, @mapColumn, @mapColumn, @LastModifiedBy, @schema, @mapTableName, @FromConfigurationID)
			set @sql = formatmessage('insert into %s.%s (ConfigurationID, %s, Previous%s, IsDeleted, LastModifiedBy) %s;', @schema, @mapTableName, @mapColumn, @mapColumn, @subSelect)

			print @sql
			exec sys.sp_executesql @sql

			fetch next from tables into @tableName
		end

		close tables
		deallocate tables

		Select ConfigurationId, 'New configuration has been created successfully.' as [Message] from dbo.tblConfigurations where ConfigurationId = @NewConfigurationID;

		COMMIT TRANSACTION CreateConfiguration
	END TRY

	BEGIN CATCH
		close tables
		deallocate tables
		ROLLBACK TRANSACTION CreateConfiguration
	END CATCH
END

GO