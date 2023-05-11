-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Copies a record for the purpose of maintaining configuration management in the database.
--   Some assumptions are made regarding the table structure:
--   1. single primary key in the table being copied
--   2. primary key is an integer
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_CopyRecord]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_CopyRecord]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_CopyRecord]
	@tableName varchar(max),
	@primaryKeyColumn varchar(max),
	@primaryKeyValue int,
	@newPrimaryKeyValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @copyColumns varchar(max)
	declare @schema varchar(max)

	-- get the schema for the table we're copying data in
	exec dbo.SP_ConfigManagement_GetTableSchema @tableName, @schema output

	-- get the list of non-primary key columns that we need to copy
	select
		@copyColumns = coalesce(@copyColumns + ',', '') + col.[name]
	from sys.tables as tab
	inner join sys.columns col
		on col.object_id = tab.object_id
	inner join sys.types y 
		on y.user_type_id = col.user_type_id
	left join sys.index_columns idx_col
		on idx_col.column_id = col.column_id and idx_col.object_id = col.object_id
	left join sys.indexes idx
		on idx.object_id = idx_col.object_id and idx.index_id = idx_col.index_id
	where 
		tab.[name] = @tableName
		and y.name != 'timestamp'
		and (idx.is_primary_key = 0 or idx.is_primary_key is null)

	-- generate a sql statement to 
	declare @sql nvarchar(max) = 'insert into ' + @schema + '.' + @tableName + ' (' + @copyColumns + ') select ' + @copyColumns + ' from ' + @schema + '.' + @tableName + ' where ' + @primaryKeyColumn + ' = ' + cast(@primaryKeyValue as varchar)
	set @sql = @sql + ';set @scopeIdentity = SCOPE_IDENTITY();'
	exec sys.sp_executesql @sql, N'@scopeIdentity int out', @scopeIdentity = @newPrimaryKeyValue out;

END

GO