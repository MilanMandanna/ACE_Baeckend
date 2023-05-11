CREATE TABLE [dbo].[tblAsxiWorldGuideTextMap]
(
	[ConfigurationID] int NULL,
	[AsxiWorldGuideTextID] int NULL,
	[PreviousAsxiWorldGuideTextID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblAsxiWorldGuideTextMap] ADD CONSTRAINT [FK_tblAsxiWorldGuidTextMap_tblAsxiWorldGuideText]
	FOREIGN KEY ([AsxiWorldGuideTextID]) REFERENCES [dbo].[tblAsxiWorldGuideText] ([AsxiWorldGuideTextID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblAsxiWorldGuideTextMap] ADD CONSTRAINT [FK_tblAsxiWorldGuidTextMap_tblConfiguration]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblAsxiWorldGuidTextMap_tblAsxiWorldGuideText] 
 ON [dbo].[tblAsxiWorldGuideTextMap] ([AsxiWorldGuideTextID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblAsxiWorldGuidTextMap_tblConfigurationReferences] 
 ON [dbo].[tblAsxiWorldGuideTextMap] ([ConfigurationID] ASC)