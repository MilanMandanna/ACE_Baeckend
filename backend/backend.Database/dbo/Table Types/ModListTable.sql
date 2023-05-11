IF TYPE_ID(N'[ModListTable]') IS NOT NULL
BEGIN
IF OBJECT_ID('[dbo].[ModListTable]','P')IS NOT NULL
BEGIN
		DROP PROC IF EXISTS [dbo].[SP_SetIsDirty]
		DROP PROC IF EXISTS [dbo].[sp_placenames_updatecattype]
		DROP PROC IF EXISTS [dbo].[sp_placenames_insertupdategeoref]
		DROP PROC IF EXISTS [dbo].[sp_placenames_insert_update_appearance]
		DROP PROC IF EXISTS [dbo].[SP_Airport_UpdateAirport]
END
DROP TYPE [dbo].[ModListTable]
CREATE TYPE [ModListTable] AS TABLE
(
	Id int,
    Row int,
	Columns int,
	Resolution int
)
END
GO