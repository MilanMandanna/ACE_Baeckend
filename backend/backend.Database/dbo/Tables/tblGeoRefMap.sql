CREATE TABLE [dbo].[tblGeoRefMap]
(
	[ConfigurationID] int NOT NULL,
	[GeoRefID] int NOT NULL,
	[PreviousGeoRefID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblGeoRefMap] ADD CONSTRAINT [FK_tblGeoRef_tblConfigurationReferences]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblGeoRefMap] ADD CONSTRAINT [FK_tblGeoRef_tblGeoRefItems]
	FOREIGN KEY ([GeoRefID]) REFERENCES [dbo].[tblGeoRef] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblGeoRef_tblACEConfiguration] 
 ON [dbo].[tblGeoRefMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblGeoRef_tblConfigurationReferences] 
 ON [dbo].[tblGeoRefMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblGeoRef_tblGeoRefItems] 
 ON [dbo].[tblGeoRefMap] ([GeoRefID] ASC)