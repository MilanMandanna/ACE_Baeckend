CREATE TABLE [dbo].[tblMetroMapGeoRefsMap]
(
	[ConfigurationID] int NULL,
	[MetroMapID] int NULL,
	[PreviousMetroMapID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblMetroMapGeoRefsMap] ADD CONSTRAINT [FK_MetroMapGeoRefsMap_tblConfiguration]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblMetroMapGeoRefsMap] ADD CONSTRAINT [FK_MetroMapGeoRefsMap_tblMetroMapGeoRefs]
	FOREIGN KEY ([MetroMapID]) REFERENCES [dbo].[tblMetroMapGeoRefs] ([MetroMapID]) ON DELETE Cascade ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_MetroMapGeoRefsMap_tblConfigurationReferences] 
 ON [dbo].[tblMetroMapGeoRefsMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_MetroMapGeoRefsMap_tblMetroMapGeoRefs] 
 ON [dbo].[tblMetroMapGeoRefsMap] ([MetroMapID] ASC)