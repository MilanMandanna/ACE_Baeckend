CREATE TABLE [dbo].[tblFontDefaultCategoryMap]
(
	[ConfigurationID] int NULL,
	[FontDefaultCategoryID] int NULL,
	[PreviousFontDefaultCategoryID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblFontDefaultCategoryMap] ADD CONSTRAINT [FK_tblFontDefaultCategoryMap_tblFontDefaultCategory]
	FOREIGN KEY ([FontDefaultCategoryID]) REFERENCES [dbo].[tblFontDefaultCategory] ([FontDefaultCategoryID]) ON DELETE Cascade ON UPDATE No Action