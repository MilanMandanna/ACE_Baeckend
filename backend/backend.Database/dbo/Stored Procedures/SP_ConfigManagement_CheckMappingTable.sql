-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:
-- Example: exec dbo.SP_ConfigManagement_CheckMappingTable 1, 'tblAirportInfo'
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_CheckMappingTable]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_CheckMappingTable]
END
GO

CREATE PROCEDURE dbo.SP_ConfigManagement_CheckMappingTable
	@configurationId int,
	@dataTable nvarchar(max)
AS
BEGIN
	declare @mapTable nvarchar(max) = @dataTable + 'Map'
	declare @count int = 0

	declare @sql nvarchar(max) = 'set @count = (select count(*) from ' + @mapTable + ' where configurationid = ' + cast(@configurationId as nvarchar(max)) + ')'
	exec sys.sp_executesql @sql, N'@count int out', @count = @count out

	if @count = 0
	begin
		print(@dataTable + ' -> map data not present')

	end
END

GO