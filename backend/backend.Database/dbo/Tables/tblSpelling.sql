CREATE TABLE [dbo].[tblSpelling]
(
	[SpellingID] int NOT NULL IDENTITY (1, 1),
	[GeoRefID] int NULL,
	[LanguageID] int NULL,
	[UnicodeStr] nvarchar(255) NULL,
	[POISpelling] nvarchar(255) NULL,
	[FontID] int NULL,
	[SphereMapFontID] int NULL,
	[DataSourceID] int NULL,
	[TimeStampModified] timestamp NOT NULL,
	[SourceDate] date NULL,
	[DoSpellCheck] bit NULL DEFAULT 0
)
GO
ALTER TABLE [dbo].[tblSpelling] 
 ADD CONSTRAINT [PK_tblSpelling]
	PRIMARY KEY CLUSTERED ([SpellingID] ASC)