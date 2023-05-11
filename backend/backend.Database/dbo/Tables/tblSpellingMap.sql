CREATE TABLE [dbo].[tblSpellingMap]
(
	[ConfigurationID] int NULL,
	[SpellingID] int NULL,
	[PreviousSpellingID] int NULL DEFAULT -1,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblSpellingMap] ADD CONSTRAINT [FK_tblSpellingMap_tblConfiguration]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblSpellingMap] ADD CONSTRAINT [FK_tblSpellingMap_tblSpelling]
	FOREIGN KEY ([SpellingID]) REFERENCES [dbo].[tblSpelling] ([SpellingID]) ON DELETE Cascade ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblSpellingMap_tblConfigurationReferences] 
 ON [dbo].[tblSpellingMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblSpellingMap_tblSpelling] 
 ON [dbo].[tblSpellingMap] ([SpellingID] ASC)