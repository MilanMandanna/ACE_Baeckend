CREATE TABLE [dbo].[tblRegionSpellingMap]
(
	[ConfigurationID] int NULL,
	[SpellingID] int NULL,
	[PreviousSpellingID] int NULL DEFAULT -1,
	[isDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblRegionSpellingMap] ADD CONSTRAINT [FK_tblRegionSpellingMap_tblConfiguration]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblRegionSpellingMap] ADD CONSTRAINT [FK_tblRegionSpellingMap_tblRegionSpelling]
	FOREIGN KEY ([SpellingID]) REFERENCES [dbo].[tblRegionSpelling] ([SpellingID]) ON DELETE No Action ON UPDATE Cascade
GO
CREATE NONCLUSTERED INDEX [IXFK_tblRegionSpellingMap_tblConfigurationReferences] 
 ON [dbo].[tblRegionSpellingMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblRegionSpellingMap_tblRegionSpelling] 
 ON [dbo].[tblRegionSpellingMap] ([SpellingID] ASC)