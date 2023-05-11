CREATE TABLE [dbo].[tblFontFamily]
(
	[FontFamilyID] int NOT NULL,
	[FontFaceID] int NULL,
	[FaceName] nvarchar(255) NULL,
	[FileName] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblFontFamily] 
 ADD CONSTRAINT [PK_tblFontFamily]
	PRIMARY KEY CLUSTERED ([FontFamilyID] ASC)