CREATE TABLE [dbo].[tblFontDefaultCategory]
(
	[FontDefaultCategoryID] int NOT NULL,
	[GeoRefIdCatTypeID] int NOT NULL,
	[Resolution] int NOT NULL,
	[FontID] int NULL,
	[SphereFontID] int NULL,
	[MarkerID] int NULL,
	[AtlasMarkerID] int NULL,
	[SphereMarkerID] int NULL
)
GO
ALTER TABLE [dbo].[tblFontDefaultCategory] 
 ADD CONSTRAINT [PK_tblFontDefaultCategory]
	PRIMARY KEY CLUSTERED ([FontDefaultCategoryID] ASC)