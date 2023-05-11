IF TYPE_ID(N'[Type_ModListJson]') IS NOT NULL
BEGIN
	IF OBJECT_ID('[dbo].[SP_UpdateModlistData]', 'P') IS NOT NULL
	BEGIN
		DROP PROC [dbo].[SP_UpdateModlistData]
	END
	DROP TYPE [dbo].[Type_ModListJson];
	
	CREATE TYPE [dbo].[Type_ModListJson] AS TABLE 
	(
		[Id] [int] NULL,
		[FileJSON] [NVARCHAR](MAX) NULL,
		[Row] [int] NULL,
		[Col] [int] NULL,
		[Resolution] [int] NULL
	);
END
GO