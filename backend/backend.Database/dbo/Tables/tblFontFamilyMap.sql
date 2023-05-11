CREATE TABLE [dbo].[tblFontFamilyMap]
(
	[ConfigurationID] int NULL,
	[FontFamilyID] int NULL,
	[PreviousFontFamilyID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblFontFamilyMap] ADD CONSTRAINT [FK_tblFontFamilyMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblFontFamilyMap] ADD CONSTRAINT [FK_tblFontFamilyMap_tblFontFamily]
	FOREIGN KEY ([FontFamilyID]) REFERENCES [dbo].[tblFontFamily] ([FontFamilyID]) ON DELETE Cascade ON UPDATE No Action