CREATE TABLE [dbo].[tblPlatformConfigurationMapping]
(
	[PlatformID] int NULL,
	[ConfigurationDefinitionID] int NULL
)
GO
ALTER TABLE [dbo].[tblPlatformConfigurationMapping] ADD CONSTRAINT [FK_tblPlatformConfigurationMapping_tblConfigurationDefinitions]
	FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE Set Null ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblPlatformConfigurationMapping] ADD CONSTRAINT [FK_tblPlatformConfigurationMapping_tblPlatforms]
	FOREIGN KEY ([PlatformID]) REFERENCES [dbo].[tblPlatforms] ([PlatformID]) ON DELETE Cascade ON UPDATE No Action