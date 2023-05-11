CREATE TABLE [dbo].[tblScreenSizeMap]
(
	[ConfigurationID] int NULL,
	[ScreenSizeID] int NULL,
	[PreviousScreenSizeID] int NULL DEFAULT -1,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblScreenSizeMap] ADD CONSTRAINT [FK_tblScreenSizeMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblScreenSizeMap] ADD CONSTRAINT [FK_tblScreenSizeMap_tblScreenSize]
	FOREIGN KEY ([ScreenSizeID]) REFERENCES [dbo].[tblScreenSize] ([ScreenSizeID]) ON DELETE Cascade ON UPDATE No Action