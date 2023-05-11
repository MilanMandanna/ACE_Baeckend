CREATE TABLE [dbo].[tblGeoRef]
(
	[ID] int NOT NULL IDENTITY (1, 1),
	[GeoRefId] int NOT NULL,	-- Collins Aerospace unique identifier for place names.
	[Description] nvarchar(255) NULL,
	[NgaUfiId] int NULL,	-- Place name description; contains some legacy data.  For internal use only.
	[NgaUniId] int NULL,	-- National Geospatial-Intelligence Agency unique name identifier for non-U.S. place names.
	[UsgsFeatureId] int NULL,	-- U.S.G.S. unique feature identifier for U.S.-based place names.
	[UnCodeId] int NULL,	-- United Nations, Statistics Division unique identifier for place names.
	[SequenceId] int NULL,	-- POI Panel feature media identifier for this place name. Used in (ASX).tbSpelling.SequenceId, (ASX Media).tbSequenceElement.SequenceId.
	[CatTypeId] int NULL,	-- Categorization of this place name.  Used in (ASXi 2D PAC/THA, iPad 1.x).tbgeorefid.GeoRefIdCatTypeId, (CES TSE).tbSpelling.FontId.
	[AsxiCatTypeId] int NULL,	-- Categorization of this place name for ASXi/Android platforms.  See tbcategorytype.
	[PnType] int NULL,	-- Dimensional type of this place name.  Values: 1 = point; 2 = line; 3 = polygon.  Used in (ASX).tbGeoRefId.PnType and (AS iPad 1.x).tbgeorefid.PnGeoType.
	[RegionId] int NULL,	-- Region assigned to this place name. Used in tbRegionSpelling.RegionId.
	[CountryId] int NULL,	-- Country assigned to this place name. Used in tbCountrySpelling.CountryId.
	[StateId] char(2) NULL,	-- U.S. state assigned to this place name. Used in (ASX).tbpnametrivia and tbUsStates.
	[TZStripId] int NULL,	-- Time zone strip ID for this place name.  Used in tbTimeZoneStrip.TZStripId.
	[isAirport] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is an airport.
	[isAirportPoi] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a city associated with an airport.
	[isAttraction] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a constructed tourist attraction (museum, theme park, etc.).
	[isCapitalCountry] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a country capital.
	[isCapitalState] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a U.S. state capital.
	[isClosestPoi] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available in the "Closest City" list. Used in (ASXi 3D).tbGeoRefId.ClosestPoi.
	[isControversial] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is the subject of cultural, political, religious, or other controversy.
	[isInteractivePoi] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available for end user interaction. Used in (ASX).tbAppearance.POI and (ASXi 3D).tbGeoRefId.IPoi.
	[isInteractiveSearch] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available for end user search.  Used in (ASXi 3D).tbgeorefid.isearch.
	[isMakkahPoi] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available for the Makkah Pointer feature.  Used in (ASXi 3D).tbgeorefid.MakkahPOI.
	[isRliPoi] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available for the Relative Location Indicator feature. Used in (ASXi 3D).tbGeoRefId.RliPoi.
	[isShipWreck] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a shipwreck site.
	[isSnapshot] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available for the Snapshots feature in ASXi.
	[isSummit] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a summit type (mount, mountain, peak).  Use isTerrainLand for mountain ranges.
	[isTerrainLand] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a topographic or land area feature (cape, island, mountain range, park, ...).
	[isTerrainOcean] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a bathymetric feature.
	[isTimeZonePoi] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available for the 3-D Time Zone feature.
	[isWaterBody] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is a water body feature (bay, river, lake, ocean, sound, ...).
	[isWorldClockPoi] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available for the World Clock feature. Used in (ASXi 3D).tbGeoRefId.WcPoi.
	[isWGuide] bit NOT NULL DEFAULT 0,	-- Indicates if this place name is available for the World Guide feature in ASXi.
	[Priority] int NULL,	-- Defines the display priority for this place name relative to other place names.  Values (high-low): 3-n.  Values 1-2 reserved for customer use.
	[AsxiPriority] int NULL,	-- Defines the ASXi-specific display priority.
	[MarkerId] int NULL,	-- Marker used to pin-point this place name. Used in (ASX).tbAppearance.MarkerId.
	[AtlasMarkerId] int NULL,	-- Atlas marker used to pin-point this place name. Used in (ASX).tbAppearance.AtlasMarkerId.
	[MapStatsAppearance] int NULL,	-- Configures which statistics to display on the map for this place name.  BIT values: 1 = distance to aircraft; 2 = elevation; 4 = population. Used in (ASXi 3.3).tbGeoRefId.LayerDisplay.
	[PoiPanelStatsAppearance] int NULL,	-- Configures which statistics to display in the POI Panel feature. Values: 1-5. Used in (ASX).tbSpelling.POIGroup.
	[RliAppearance] int NULL,	-- Configures the availability of this place name in the RLI feature. BIT values: 0 = exclude; 1 = closest city; 4 = user selectable; 5 = 1 and 4. Used in (ASXi PAC/THA, AS Mobile).tbgeorefid.POIType.
	[KeepNew] bit NOT NULL DEFAULT 0,	-- Used in SystemAsx for the DB Merge process.
	[Display] bit NOT NULL DEFAULT 0,
	[CustomChangeBitMask] int NOT NULL DEFAULT 0
)
GO
ALTER TABLE [dbo].[tblGeoRef] 
 ADD CONSTRAINT [PK_tblGeoRefItems]
	PRIMARY KEY CLUSTERED ([ID] ASC)
GO
EXEC sp_addextendedproperty 'MS_Description', 'Collins Aerospace unique identifier for place names.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [GeoRefId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Place name description; contains some legacy data.  For internal use only.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [NgaUfiId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'National Geospatial-Intelligence Agency unique name identifier for non-U.S. place names.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [NgaUniId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'U.S.G.S. unique feature identifier for U.S.-based place names.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [UsgsFeatureId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'United Nations, Statistics Division unique identifier for place names.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [UnCodeId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'POI Panel feature media identifier for this place name. Used in (ASX).tbSpelling.SequenceId, (ASX Media).tbSequenceElement.SequenceId.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [SequenceId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Categorization of this place name.  Used in (ASXi 2D PAC/THA, iPad 1.x).tbgeorefid.GeoRefIdCatTypeId, (CES TSE).tbSpelling.FontId.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [CatTypeId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Categorization of this place name for ASXi/Android platforms.  See tbcategorytype.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [AsxiCatTypeId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Dimensional type of this place name.  Values: 1 = point; 2 = line; 3 = polygon.  Used in (ASX).tbGeoRefId.PnType and (AS iPad 1.x).tbgeorefid.PnGeoType.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [PnType]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Region assigned to this place name. Used in tbRegionSpelling.RegionId.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [RegionId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Country assigned to this place name. Used in tbCountrySpelling.CountryId.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [CountryId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'U.S. state assigned to this place name. Used in (ASX).tbpnametrivia and tbUsStates.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [StateId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Time zone strip ID for this place name.  Used in tbTimeZoneStrip.TZStripId.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [TZStripId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is an airport.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isAirport]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a city associated with an airport.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isAirportPoi]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a constructed tourist attraction (museum, theme park, etc.).', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isAttraction]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a country capital.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isCapitalCountry]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a U.S. state capital.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isCapitalState]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available in the "Closest City" list. Used in (ASXi 3D).tbGeoRefId.ClosestPoi.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isClosestPoi]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is the subject of cultural, political, religious, or other controversy.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isControversial]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available for end user interaction. Used in (ASX).tbAppearance.POI and (ASXi 3D).tbGeoRefId.IPoi.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isInteractivePoi]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available for end user search.  Used in (ASXi 3D).tbgeorefid.isearch.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isInteractiveSearch]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available for the Makkah Pointer feature.  Used in (ASXi 3D).tbgeorefid.MakkahPOI.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isMakkahPoi]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available for the Relative Location Indicator feature. Used in (ASXi 3D).tbGeoRefId.RliPoi.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isRliPoi]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a shipwreck site.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isShipWreck]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available for the Snapshots feature in ASXi.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isSnapshot]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a summit type (mount, mountain, peak).  Use isTerrainLand for mountain ranges.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isSummit]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a topographic or land area feature (cape, island, mountain range, park, ...).', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isTerrainLand]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a bathymetric feature.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isTerrainOcean]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available for the 3-D Time Zone feature.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isTimeZonePoi]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is a water body feature (bay, river, lake, ocean, sound, ...).', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isWaterBody]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available for the World Clock feature. Used in (ASXi 3D).tbGeoRefId.WcPoi.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isWorldClockPoi]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates if this place name is available for the World Guide feature in ASXi.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [isWGuide]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Defines the display priority for this place name relative to other place names.  Values (high-low): 3-n.  Values 1-2 reserved for customer use.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [Priority]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Defines the ASXi-specific display priority.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [AsxiPriority]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Marker used to pin-point this place name. Used in (ASX).tbAppearance.MarkerId.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [MarkerId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Atlas marker used to pin-point this place name. Used in (ASX).tbAppearance.AtlasMarkerId.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [AtlasMarkerId]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Configures which statistics to display on the map for this place name.  BIT values: 1 = distance to aircraft; 2 = elevation; 4 = population. Used in (ASXi 3.3).tbGeoRefId.LayerDisplay.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [MapStatsAppearance]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Configures which statistics to display in the POI Panel feature. Values: 1-5. Used in (ASX).tbSpelling.POIGroup.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [PoiPanelStatsAppearance]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Configures the availability of this place name in the RLI feature. BIT values: 0 = exclude; 1 = closest city; 4 = user selectable; 5 = 1 and 4. Used in (ASXi PAC/THA, AS Mobile).tbgeorefid.POIType.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [RliAppearance]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Used in SystemAsx for the DB Merge process.', 'Schema', [dbo], 'table', [tblGeoRef], 'column', [KeepNew]