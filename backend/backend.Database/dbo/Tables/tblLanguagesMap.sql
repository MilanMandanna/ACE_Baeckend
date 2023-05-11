CREATE TABLE [dbo].[tblLanguagesMap]
(
	[ConfigurationID] int NULL,
	[LanguageID] int NULL,
	[PreviousLanguageID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblLanguagesMap] ADD CONSTRAINT [FK_tblLanguagesMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblLanguagesMap] ADD CONSTRAINT [FK_tblLanguagesMap_tblLanguages]
	FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[tblLanguages] ([ID]) ON DELETE Cascade ON UPDATE No Action