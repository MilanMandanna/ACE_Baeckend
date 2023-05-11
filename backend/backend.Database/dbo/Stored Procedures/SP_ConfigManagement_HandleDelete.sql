-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Updates the mapping table associated with the specified data table in order
--   to mark a record as deleted
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleDelete]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleDelete]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleDelete]
	@configurationId int,
	@dataTable varchar(max),
	@keyValue int
AS
BEGIN
	set nocount on

	declare @mapTable varchar(max) = @dataTable + 'Map'
	declare @mapColumn varchar(max)
	declare @dataColumn varchar(max)
	declare @mapSchema varchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	--Update last update date time for the config

	exec SP_ConfigManagement_SetLastUpdateDateTime @configurationId

	-- flag the mapping record as deleted
	declare @sql nvarchar(max) = 'update ' + @mapSchema + '.' + @mapTable + ' set isdeleted = 1 where configurationId = ' + cast(@configurationId as nvarchar) + ' and ' + @mapColumn + ' = ' + cast(@keyValue as nvarchar)
	exec sys.sp_executesql @sql
END

GO