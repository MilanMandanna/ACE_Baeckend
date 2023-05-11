CREATE TABLE [dbo].[tblMetroMapGeoRefs]
(
	[MetroMapID] int NOT NULL IDENTITY (1, 1),
	[GeoRefID] int NULL,
	[Description] nvarchar(255) NULL,
	[Priority] smallint NULL,	-- Defines the display priority for this place name relative to other place names.  Values (high-low): 3-n.  Values 1-2 reserved for customer use.
	[MarkerId] int NULL,	-- Marker used to pin-point this place name. Refers to tblAppearance.MarkerId.
	[AtlasMarkerID] int NULL,	-- Atlas marker used to pin-point this place name. Refers to tblAppearance.AtlasMarkerId.
	[FontID] int NULL,
	[SphereMapFontID] int NULL
)
GO
ALTER TABLE [dbo].[tblMetroMapGeoRefs] 
 ADD CONSTRAINT [PK_tblMetroMapGeoRefs]
	PRIMARY KEY CLUSTERED ([MetroMapID] ASC)
GO
EXEC sp_addextendedproperty 'MS_Description', 'Defines the display priority for this place name relative to other place names.  Values (high-low): 3-n.  Values 1-2 reserved for customer use.', 'Schema', [dbo], 'table', [tblMetroMapGeoRefs], 'column', [Priority]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Marker used to pin-point this place name. Refers to tblAppearance.MarkerId.', 'Schema', [dbo], 'table', [tblMetroMapGeoRefs], 'column', [MarkerId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Atlas marker used to pin-point this place name. Refers to tblAppearance.AtlasMarkerId.', 'Schema', [dbo], 'table', [tblMetroMapGeoRefs], 'column', [AtlasMarkerID]