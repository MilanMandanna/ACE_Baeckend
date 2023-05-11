IF TYPE_ID(N'[Type_PlatformData]') IS NOT NULL
BEGIN
	IF OBJECT_ID('[dbo].[SP_SaveProductConfigurationData]', 'P') IS NOT NULL
	BEGIN
		DROP PROC [dbo].[SP_SaveProductConfigurationData]
	END
	DROP TYPE [dbo].[Type_PlatformData];
	
	CREATE TYPE [dbo].[Type_PlatformData] AS TABLE 
	(
		[ConfigurationDefinitionID] [INT] NULL,
		[PlatformName] [NVARCHAR](MAX) NULL,
		[PlatformDescription] [NVARCHAR](MAX) NULL,
		[PlatformId] [INT] NULL,
		[InstallationTypeID] [UNIQUEIDENTIFIER] NULL
	);
END
GO