CREATE TABLE [dbo].[tblFontCategoryMap]
(
	[ConfigurationID] int NULL,
	[FontCategoryID] int NULL,
	[PreviousFontCategoryID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblFontCategoryMap] ADD CONSTRAINT [FK_tblFontCategoryMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblFontCategoryMap] ADD CONSTRAINT [FK_tblFontCategoryMap_tblFontCategory]
	FOREIGN KEY ([FontCategoryID]) REFERENCES [dbo].[tblFontCategory] ([FontCategoryID]) ON DELETE Cascade ON UPDATE No Action