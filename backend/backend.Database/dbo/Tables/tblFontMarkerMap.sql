CREATE TABLE [dbo].[tblFontMarkerMap]
(
	[ConfigurationID] int NOT NULL,
	[FontMarkerID] int NULL,
	[PreviousFontMarkerID] int NULL DEFAULT -1,
	[isDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblFontMarkerMap] ADD CONSTRAINT [FK_tblFontMarkerMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblFontMarkerMap] ADD CONSTRAINT [FK_tblFontMarkerMap_tblFontMarker]
	FOREIGN KEY ([FontMarkerID]) REFERENCES [dbo].[tblFontMarker] ([FontMarkerID]) ON DELETE Cascade ON UPDATE No Action