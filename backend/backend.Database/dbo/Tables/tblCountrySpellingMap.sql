CREATE TABLE [dbo].[tblCountrySpellingMap]
(
	[ConfigurationID] int NULL,
	[CountrySpellingID] int NULL,
	[PreviousCountrySpellingID] int NULL DEFAULT -1,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblCountrySpellingMap] ADD CONSTRAINT [FK_CountrySpellingMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblCountrySpellingMap] ADD CONSTRAINT [FK_CountrySpellingMap_tblCountrySpelling]
	FOREIGN KEY ([CountrySpellingID]) REFERENCES [dbo].[tblCountrySpelling] ([CountrySpellingID]) ON DELETE Cascade ON UPDATE No Action