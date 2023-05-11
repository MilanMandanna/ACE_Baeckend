CREATE TABLE [dbo].[tblCountrySpelling]
(
	[CountrySpellingID] int NOT NULL IDENTITY (1, 1),
	[CountryID] int NULL,
	[CountryName] nvarchar(255) NULL,
	[LanguageID] int NULL,
	[doSpellCheck] bit NULL DEFAULT 0
)
GO
ALTER TABLE [dbo].[tblCountrySpelling] ADD CONSTRAINT [FK_tblCountrySpelling_tblCountry]
	FOREIGN KEY ([CountryID]) REFERENCES [dbo].[tblCountry] ([CountryID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblCountrySpelling] 
 ADD CONSTRAINT [PK_tblCountrySpelling]
	PRIMARY KEY CLUSTERED ([CountrySpellingID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblCountrySpelling_tblCountry] 
 ON [dbo].[tblCountrySpelling] ([CountryID] ASC)