CREATE TABLE [dbo].[tblRegionSpelling]
(
	[SpellingID] int NOT NULL IDENTITY (1, 1),
	[RegionID] int NULL,
	[RegionName] nvarchar(255) NULL,
	[LanguageId] int NULL
)
GO
ALTER TABLE [dbo].[tblRegionSpelling] 
 ADD CONSTRAINT [PK_tblRegionSpelling]
	PRIMARY KEY CLUSTERED ([SpellingID] ASC)