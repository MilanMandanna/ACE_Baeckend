CREATE TABLE [dbo].[tblFontMap]
(
	[ConfigurationID] int NULL,
	[FontID] int NULL,
	[PreviousFontID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblFontMap] ADD CONSTRAINT [FK_tblFontMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblFontMap] ADD CONSTRAINT [FK_tblFontMap_tblFont]
	FOREIGN KEY ([FontID]) REFERENCES [dbo].[tblFont] ([FontID]) ON DELETE Cascade ON UPDATE No Action