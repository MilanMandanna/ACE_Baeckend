-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/17/2022
-- Description:	Used to handle record updates to records under configuration management. Updates are a bit more trickier
--   then adds or deletes. For updates, we need to create a copy of the record being updated and branch it just for the
--   configuration being updated, and then apply the updates. This procedure is responsible for detecting when a branch
--   needs to be made, copying the record, and providing the unique id of the branched record that can then be updated.
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleUpdate]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleUpdate]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleUpdate]
	@configurationId int,
	@dataTable varchar(max),
	@keyValue int,
	@useKeyValue int output			-- this is the output key that the calling stored procedure should use for applying the updates
AS
BEGIN
	set nocount on

	declare @mapTable varchar(max) = @dataTable + 'Map'
	declare @mapColumn varchar(max)
	declare @dataColumn varchar(max)
	declare @mapSchema varchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	declare @count int
	declare @sql nvarchar(max) = 'set @count = (select count(*) from ' + @mapSchema + '.' + @mapTable + ' where ' + @mapColumn + ' = ' + cast(@keyValue as nvarchar) + ')'
	exec sys.sp_executesql @sql, N'@count int out', @count = @count out

	--Update last update date time for the config
	exec SP_ConfigManagement_SetLastUpdateDateTime @configurationId
    -- record is only mapped to one configuration, which should be the current one, do nothing
    if @count <= 1
    begin
        set @useKeyValue = @keyValue
        return
    end
 
    -- create a copy of the record and update the mapping to point to it and connect the history
    declare @copyKey int
    exec dbo.SP_ConfigManagement_CopyRecord @dataTable, @dataColumn, @keyValue, @copyKey out
 
    -- update the mapping record for the configuration to point to the new record created
    set @sql = 'update ' + @mapSchema + '.' + @mapTable + ' set ' +  @mapColumn + ' = ' + cast(@copyKey as nvarchar) + ', ' + 'Previous' + @mapColumn + ' = ' + cast(@keyValue as nvarchar) + ' where configurationId = ' + cast(@configurationId as nvarchar) + ' and ' + @mapColumn + ' = ' + cast(@keyValue as nvarchar)
    exec sys.sp_executesql @sql
 
    set @useKeyValue = @copyKey
 
END

GO