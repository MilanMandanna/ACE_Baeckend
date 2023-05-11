CREATE TABLE [dbo].[tblWGtextMap]
(
	[ConfigurationID] int NULL,
	[WGtextID] int NULL,
	[PreviousWGtextID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblWGtextMap] ADD CONSTRAINT [FK_tblWGtextMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblWGtextMap] ADD CONSTRAINT [FK_tblWGtextMap_tblWGtext]
	FOREIGN KEY ([WGtextID]) REFERENCES [dbo].[tblWGtext] ([WGtextID]) ON DELETE Cascade ON UPDATE No Action