CREATE TABLE [dbo].[tblWGTypeMap]
(
	[ConfigurationID] int NULL,
	[WGTypeID] int NULL,
	[PreviousWGTypeID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblWGTypeMap] ADD CONSTRAINT [FK_tblWGTypeMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblWGTypeMap] ADD CONSTRAINT [FK_tblWGTypeMap_tblWGType]
	FOREIGN KEY ([WGTypeID]) REFERENCES [dbo].[tblWGType] ([WGTypeID]) ON DELETE Cascade ON UPDATE No Action