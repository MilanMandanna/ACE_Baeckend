-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns config mapped records
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetMappedConfigurationRecords]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetMappedConfigurationRecords]
END
GO

CREATE PROCEDURE [dbo].[SP_GetMappedConfigurationRecords]
	@ConfigurationID int,
	@DataTable nvarchar(100),
	@primaryColumn nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @theSql nvarchar(1000)
	DECLARE @mappingTable varchar(250)
	 SET @mappingTable = @DataTable + 'Map'
	   SET @theSql = 'SELECT DataTable.* '
	   SET @theSql = @theSql + 'FROM ' + @DataTable + ' AS DataTable '
	IF (@DataTable = 'dbo.tblwgimage')
	BEGIN
		 SET @theSql = @theSql + 'INNER JOIN ' + @DataTable + 'Map AS Mapping ON DataTable.' + @primaryColumn + ' = Mapping.Image' + @primaryColumn + ' '
	END
	ELSE
	BEGIN
	   SET @theSql = @theSql + 'INNER JOIN ' + @DataTable + 'Map AS Mapping ON DataTable.' + @primaryColumn + ' = Mapping.' + @primaryColumn + ' '
	END
	SET @theSql = @theSql + 'WHERE Mapping.ConfigurationID = ' + CAST(@ConfigurationID as nvarchar) +' AND Mapping.isDeleted=0'

	EXECUTE dbo.sp_executesql @theSql
END

GO