CREATE TABLE [dbo].[tblConfigurationComponentsMap]
(
	[ConfigurationID] int NULL,
	[ConfigurationComponentID] int NULL,
	[PreviousConfigurationComponentID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblConfigurationComponentsMap] ADD CONSTRAINT [FK_tbconfigCompMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblConfigurationComponentsMap] ADD CONSTRAINT [FK_tblConfigurationComponentsMap_tblConfigurationComponents_02]
	FOREIGN KEY ([ConfigurationComponentID]) REFERENCES [dbo].[tblConfigurationComponents] ([ConfigurationComponentID]) ON DELETE No Action ON UPDATE No Action