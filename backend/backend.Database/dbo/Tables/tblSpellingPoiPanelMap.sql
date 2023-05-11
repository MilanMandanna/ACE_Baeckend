CREATE TABLE [dbo].[tblSpellingPoiPanelMap]
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
ALTER TABLE [dbo].[tblSpellingPoiPanelMap] ADD CONSTRAINT [FK_tblSpellingPoiPanelMap_tblConfiguration]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblSpellingPoiPanelMap] ADD CONSTRAINT [FK_tblSpellingPoiPanelMap_tblSpellingPoiPanel]
	FOREIGN KEY ([SpellingID]) REFERENCES [dbo].[tblSpellingPoiPanel] ([SpellingID]) ON DELETE Cascade ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblSpellingPoiPanelMap_tblConfigurationReferences] 
 ON [dbo].[tblSpellingPoiPanelMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblSpellingPoiPanelMap_tblSpellingPoiPanel] 
 ON [dbo].[tblSpellingPoiPanelMap] ([SpellingID] ASC)