CREATE TABLE [dbo].[tblFontFileSelection]
(
	[FontFileSelectionID] int NOT NULL IDENTITY (1, 1),
	[FontFileID] int NULL
)
GO
ALTER TABLE [dbo].[tblFontFileSelection] 
 ADD CONSTRAINT [PK_tblFontFileSelection]
	PRIMARY KEY CLUSTERED ([FontFileSelectionID] ASC)