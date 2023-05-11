CREATE TABLE [dbo].[tblFontTextEffectMap]
(
	[ConfigurationID] int NULL,
	[FontTextEffectID] int NULL,
	[PreviousFontTextEffectID] int NULL DEFAULT -1,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblFontTextEffectMap] ADD CONSTRAINT [FK_tblFontTextEffectMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblFontTextEffectMap] ADD CONSTRAINT [FK_tblFontTextEffectMap_tblFontTextEffect]
	FOREIGN KEY ([FontTextEffectID]) REFERENCES [dbo].[tblFontTextEffect] ([FontTextEffectID]) ON DELETE Cascade ON UPDATE No Action