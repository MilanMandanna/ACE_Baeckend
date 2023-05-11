-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Handles populating the corresponding map table when a new record is inserted into a data table
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleAdd]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleAdd]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleAdd]
	@configurationId int,
	@dataTable nvarchar(max),
	@keyValue int
AS
BEGIN
	set nocount on

	declare @mapTable nvarchar(max) = @dataTable + 'Map'
	declare @mapColumn nvarchar(max)
	declare @dataColumn nvarchar(max)
	declare @mapSchema nvarchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	declare @sql nvarchar(max) = 'insert into ' + @mapSchema + '.' + @dataTable + 'Map (' + @mapColumn + ', Previous' + @mapColumn + ', ConfigurationID, IsDeleted, Action) values (' + cast(@keyValue as nvarchar) + ', 0, ' + cast(@configurationId as nvarchar) + ', 0, ''adding'')'
	exec sys.sp_executesql @sql
END

GO