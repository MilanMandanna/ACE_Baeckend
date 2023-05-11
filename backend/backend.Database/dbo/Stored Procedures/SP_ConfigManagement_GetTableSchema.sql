-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 02/28/2022
-- Description:	Queries the database and retrieves the schema for a given table
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_GetTableSchema]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_GetTableSchema]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_GetTableSchema]
	@tableName varchar(max),
	@schema varchar(max) output
AS
BEGIN
	set nocount on

	select
		@schema = schemas.[name]
	from sys.schemas schemas
		inner join sys.tables tab on tab.schema_id = schemas.schema_id and tab.[name] = @tableName
END

GO