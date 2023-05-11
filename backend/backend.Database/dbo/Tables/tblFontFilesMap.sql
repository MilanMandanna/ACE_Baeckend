CREATE TABLE [dbo].[tblFontFilesMap]
(
	[ConfigurationID] int NULL,
	[FontFileID] int NULL,
	[PreviousFontFileID] int NULL,
	[IsDeleted] bit NULL,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(255) NULL,
	[Action] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblFontFilesMap] ADD CONSTRAINT [FK_tblFontFilesMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblFontFilesMap] ADD CONSTRAINT [FK_tblFontFilesMap_tblFontFiles]
	FOREIGN KEY ([FontFileID]) REFERENCES [dbo].[tblFontFiles] ([FontFileID]) ON DELETE No Action ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblFontFilesMap_tblConfigurations] 
 ON [dbo].[tblFontFilesMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblFontFilesMap_tblFontFiles] 
 ON [dbo].[tblFontFilesMap] ([FontFileID] ASC)