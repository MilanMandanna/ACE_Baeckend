CREATE TABLE [dbo].[tblWGImageMap]
(
	[ConfigurationID] int NULL,
	[ImageID] int NULL,
	[PreviousImageID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblWGImageMap] ADD CONSTRAINT [FK_tblWGImageMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblWGImageMap] ADD CONSTRAINT [FK_tblWGImageMap_tblWGImage]
	FOREIGN KEY ([ImageID]) REFERENCES [dbo].[tblWGImage] ([ID]) ON DELETE No Action ON UPDATE No Action