CREATE TABLE [dbo].[tblFontFileSelectionMap]
(
	[ConfigurationID] int NULL,
	[FontFileSelectionID] int NULL,
	[PreviousFontFileSelectionID] int NULL,
	[IsDeleted] bit NULL,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblFontFileSelectionMap] ADD CONSTRAINT [FK_tblFontFileSelectionMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblFontFileSelectionMap] ADD CONSTRAINT [FK_tblFontFileSelectionMap_tblFontFileSelection]
	FOREIGN KEY ([FontFileSelectionID]) REFERENCES [dbo].[tblFontFileSelection] ([FontFileSelectionID]) ON DELETE No Action ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblFontFileSelectionMap_tblConfigurations] 
 ON [dbo].[tblFontFileSelectionMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblFontFileSelectionMap_tblFontFileSelection] 
 ON [dbo].[tblFontFileSelectionMap] ([FontFileSelectionID] ASC)