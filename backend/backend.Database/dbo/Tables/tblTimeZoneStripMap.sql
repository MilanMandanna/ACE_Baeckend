CREATE TABLE [dbo].[tblTimeZoneStripMap]
(
	[ConfigurationID] int NULL,
	[TimeZoneStripID] int NULL,
	[PreviousTimeZonStripID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblTimeZoneStripMap] ADD CONSTRAINT [FK_tblTimeZoneStripMap_tblConfiguration]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblTimeZoneStripMap] ADD CONSTRAINT [FK_tblTimeZoneStripMap_tblTimeZoneStrip]
	FOREIGN KEY ([TimeZoneStripID]) REFERENCES [dbo].[tblTimeZoneStrip] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblTimeZoneStripMap_tblConfigurationReferences] 
 ON [dbo].[tblTimeZoneStripMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblTimeZoneStripMap_tblTimeZoneStrip] 
 ON [dbo].[tblTimeZoneStripMap] ([TimeZoneStripID] ASC)