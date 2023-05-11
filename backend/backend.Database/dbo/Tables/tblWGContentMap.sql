CREATE TABLE [dbo].[tblWGContentMap]
(
	[ConfigurationID] int NULL,
	[WGContentID] int NULL,
	[PreviousWGContentID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblWGContentMap] ADD CONSTRAINT [FK_tblWGContentMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblWGContentMap] ADD CONSTRAINT [FK_tblWGContentMap_tblWGContent]
	FOREIGN KEY ([WGContentID]) REFERENCES [dbo].[tblWGContent] ([WGContentID]) ON DELETE Cascade ON UPDATE No Action