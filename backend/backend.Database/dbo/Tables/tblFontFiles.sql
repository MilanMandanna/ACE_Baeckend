CREATE TABLE [dbo].[tblFontFiles]
(
	[FontFileID] int NOT NULL IDENTITY (1, 1),
	[Name] nvarchar(255) NULL,
	[Description] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblFontFiles] 
 ADD CONSTRAINT [PK_tblFontFiles]
	PRIMARY KEY CLUSTERED ([FontFileID] ASC)