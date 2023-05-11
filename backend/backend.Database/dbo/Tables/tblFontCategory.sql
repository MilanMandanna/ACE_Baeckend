CREATE TABLE [dbo].[tblFontCategory]
(
	[FontCategoryID] int NOT NULL,
	[GeoRefIdCatTypeID] int NULL DEFAULT 0,
	[LanguageID] int NULL DEFAULT 0,
	[FontID] int NULL,
	[MarkerID] int NULL,
	[IMarkerID] int NULL
)
GO
ALTER TABLE [dbo].[tblFontCategory] 
 ADD CONSTRAINT [PK_tblFontCategory]
	PRIMARY KEY CLUSTERED ([FontCategoryID] ASC)