CREATE TABLE [dbo].[tblCountryMap]
(
	[ConfigurationID] int NULL,
	[CountryID] int NULL,
	[PreviousCountryID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblCountryMap] ADD CONSTRAINT [FK_tblCountryMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblCountryMap] ADD CONSTRAINT [FK_tblCountryMap_tblCountry]
	FOREIGN KEY ([CountryID]) REFERENCES [dbo].[tblCountry] ([CountryID]) ON DELETE Cascade ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblCountryMap_tblConfigurations] 
 ON [dbo].[tblCountryMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblCountryMap_tblCountry] 
 ON [dbo].[tblCountryMap] ([CountryID] ASC)