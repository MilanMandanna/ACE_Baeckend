-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Looks up the key columns to used when connecting the two tables requested. The assumption here is that the two are linked by a single column.
--   If multiple are present then only the first one is returned.
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_FindMappingBetween]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_FindMappingBetween]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_FindMappingBetween]
	@mapTable varchar(max),
	@dataTable varchar(max),
	@mapColumn varchar(max) output,
	@dataColumn varchar(max) output,
	@mapSchema varchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	select top 1
		@mapColumn = col.[name],
		@dataColumn = data_col.[name],
		@mapSchema = schemas.[name]
	from sys.foreign_keys fk
		inner join sys.tables tab
			on tab.object_id = fk.parent_object_id
		inner join sys.tables data_table
			on data_table.object_id = fk.referenced_object_id and data_table.[name] = @dataTable
		inner join sys.foreign_key_columns fk_col
			on fk_col.constraint_object_id = fk.object_id
		inner join sys.columns col
			on col.column_id = fk_col.parent_column_id and col.object_id = fk_col.parent_object_id
		inner join sys.columns data_col
			on data_col.column_id = fk_col.referenced_column_id and data_col.object_id = fk_col.referenced_object_id
		inner join sys.schemas schemas
			on schemas.schema_id = tab.schema_id
	where tab.[name] = @mapTable
END

GO