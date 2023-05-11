IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_SpellingMapIndex' AND object_id = OBJECT_ID('tblSpellingMap'))
    BEGIN
       CREATE NONCLUSTERED INDEX ix_SpellingMapIndex ON dbo.tblSpellingMap (ConfigurationID, IsDeleted) INCLUDE (SpellingID)
    END

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_GeoRefMapIndex' AND object_id = OBJECT_ID('tblGeoRefMap'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_GeoRefMapIndex ON dbo.tblGeoRefMap (ConfigurationID, IsDeleted) INCLUDE (GeoRefID)
    END

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_SpellingMapIndex' AND object_id = OBJECT_ID('tblSpellingMap'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_SpellingMapIndex ON dbo.tblSpellingMap (ConfigurationID, IsDeleted) INCLUDE (SpellingID)
    END
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_GeoRefMapIndex' AND object_id = OBJECT_ID('tblGeoRefMap'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_GeoRefMapIndex ON dbo.tblGeoRefMap (ConfigurationID, IsDeleted) INCLUDE (GeoRefID)
    END
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_SpellingIndex' AND object_id = OBJECT_ID('tblSpelling'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_SpellingIndex ON dbo.tblSpelling (GeoRefID) INCLUDE (LanguageID, UnicodeStr)
    END
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_CoverageSegmentMapIndex' AND object_id = OBJECT_ID('tblCoverageSegmentMap'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_CoverageSegmentMapIndex ON dbo.tblCoverageSegmentMap (ConfigurationID, IsDeleted) INCLUDE (CoverageSegmentID)
    END

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_ElevationMapIndex' AND object_id = OBJECT_ID('tblElevationMap'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_ElevationMapIndex ON dbo.tblElevationMap (ConfigurationID, IsDeleted) INCLUDE (ElevationID)
    END
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_CityPopulationMapIndex' AND object_id = OBJECT_ID('tblCityPopulationMap'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_CityPopulationMapIndex ON dbo.tblCityPopulationMap (ConfigurationID, IsDeleted) INCLUDE (CityPopulationID)
    END
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_AirportInfoMapIndex' AND object_id = OBJECT_ID('tblAirportInfoMap'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_AirportInfoMapIndex ON dbo.tblAirportInfoMap (ConfigurationID, IsDeleted) INCLUDE (AirportInfoID)
    END
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_AppearanceMapIndex' AND object_id = OBJECT_ID('tblAppearanceMap'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_AppearanceMapIndex ON dbo.tblAppearanceMap (ConfigurationID, IsDeleted) INCLUDE (AppearanceID)
    END	
		
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_Appearance' AND object_id = OBJECT_ID('tblAppearance'))
    BEGIN
CREATE NONCLUSTERED INDEX ix_Appearance ON dbo.tblAppearance (GeoRefID, Resolution) INCLUDE (Exclude, SphereMapExclude)
    END	
		
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblMetroMapGeoRefsMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblMetroMapGeoRefsMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblMetroMapGeoRefsMap_configID_IsDeleted
ON [dbo].[tblMetroMapGeoRefsMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([MetroMapID],[PreviousMetroMapID])
    END	
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblAirportInfoMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblAirportInfoMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblAirportInfoMap_configID_IsDeleted
ON [dbo].[tblAirportInfoMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([AirportInfoID],[PreviousAirportInfoID])
    END	
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblAppearanceMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblAppearanceMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblAppearanceMap_configID_IsDeleted
ON [dbo].[tblAppearanceMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([AppearanceID],[PreviousAppearanceID])
    END
	

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblCityPopulationMapp_configID_IsDeleted' AND object_id = OBJECT_ID('tblCityPopulationMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblCityPopulationMapp_configID_IsDeleted
ON [dbo].[tblCityPopulationMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([CityPopulationID],[PreviousCityPopulationID])
    END



IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblInfoSpellingMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblInfoSpellingMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblInfoSpellingMap_configID_IsDeleted
ON [dbo].[tblInfoSpellingMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([InfoSpellingID],[PreviousInfoSpellingID])
    END


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblCountrySpellingMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblCountrySpellingMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblCountrySpellingMap_configID_IsDeleted
ON [dbo].[tblCountrySpellingMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([CountrySpellingID],[PreviousCountrySpellingID])
    END
	
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblSpellingMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblSpellingMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblSpellingMap_configID_IsDeleted
ON [dbo].[tblSpellingMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([SpellingID],[PreviousSpellingID])
    END

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblCoverageSegmentMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblCoverageSegmentMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblCoverageSegmentMap_configID_IsDeleted
ON [dbo].[tblCoverageSegmentMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([CoverageSegmentID],[PreviousCoverageSegmentID])
    END
	


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblSpellingPoiPanelMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblSpellingPoiPanelMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblSpellingPoiPanelMap_configID_IsDeleted
ON [dbo].[tblSpellingPoiPanelMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([SpellingID],[PreviousSpellingID])
    END
	

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblElevationMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblElevationMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblElevationMap_configID_IsDeleted
ON [dbo].[tblElevationMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([ElevationID],[PreviousElevationID])
    END
	
	

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblFontCategoryMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblFontCategoryMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblFontCategoryMap_configID_IsDeleted
ON [dbo].[tblFontCategoryMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([FontCategoryID],[PreviousFontCategoryID])
    END	


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblFontMap_configID_IsDeleted' AND object_id = OBJECT_ID('tblFontMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblFontMap_configID_IsDeleted
ON [dbo].[tblFontMap] ([ConfigurationID],[IsDeleted])
INCLUDE ([FontID],[PreviousFontID])
    END	



IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblFont_FontID' AND object_id = OBJECT_ID('tblFont'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblFont_FontID ON [dbo].[tblFont] ([FontID]) INCLUDE ([Color], [Description], [FontFaceId], [FontStyle], [PxSize], [ShadowColor], [Size], [TextEffectId])
    END	


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblAppearanceMap_ConfigurationID_PreviousAppearanceID' AND object_id = OBJECT_ID('tblAppearanceMap'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblAppearanceMap_ConfigurationID_PreviousAppearanceID ON [dbo].[tblAppearanceMap] ([ConfigurationID], [IsDeleted], [PreviousAppearanceID]) INCLUDE ([AppearanceID]) 
    END	



IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblFontCategory_GeoRefIdCatTypeID' AND object_id = OBJECT_ID('tblFontCategory'))
    BEGIN
CREATE NONCLUSTERED INDEX idx_tblFontCategory_GeoRefIdCatTypeID ON [dbo].[tblFontCategory] ([GeoRefIdCatTypeID], [LanguageID], [Resolution]) INCLUDE ([FontID], [MarkerID])
    END	




IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_tblGeoRefMap_ConfigurationID_IsDeleted' AND object_id = OBJECT_ID('tblGeoRefMap'))
    BEGIN

CREATE NONCLUSTERED INDEX idx_tblGeoRefMap_ConfigurationID_IsDeleted ON [dbo].[tblGeoRefMap] ([ConfigurationID], [IsDeleted], [PreviousGeoRefID]) INCLUDE ([GeoRefID])
    END	





