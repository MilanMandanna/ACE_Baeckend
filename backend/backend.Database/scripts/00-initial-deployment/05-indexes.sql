
IF NOT EXISTS(SELECT 1
FROM sys.indexes 
WHERE name='idx_tblInfoSpellingMap' AND object_id = OBJECT_ID('[dbo].[tblInfoSpellingMap]'))
BEGIN
CREATE NONCLUSTERED INDEX idx_tblInfoSpellingMap
ON [dbo].[tblInfoSpellingMap] ([ConfigurationID])
INCLUDE ([InfoSpellingID])
END

IF NOT EXISTS(SELECT 1
FROM sys.indexes 
WHERE name='idx_tblInfoSpellingMap' AND object_id = OBJECT_ID('[dbo].[tblFontCategoryMap]'))
BEGIN
CREATE NONCLUSTERED INDEX idx_tblInfoSpellingMap
ON [dbo].[tblFontCategoryMap] ([ConfigurationID])
INCLUDE ([FontCategoryID])
END

IF NOT EXISTS(SELECT 1
FROM sys.indexes 
WHERE name='idx_tblWGImageMap' AND object_id = OBJECT_ID('[dbo].[tblWGImageMap]'))
BEGIN
CREATE NONCLUSTERED INDEX idx_tblWGImageMap
ON [dbo].[tblWGImageMap] ([ConfigurationID])
INCLUDE ([ImageID])
END

IF NOT EXISTS(SELECT 1
FROM sys.indexes 
WHERE name='idx_tblCityPopulationMap' AND object_id = OBJECT_ID('[dbo].[tblCityPopulationMap]'))
BEGIN
CREATE NONCLUSTERED INDEX idx_tblCityPopulationMap
ON [dbo].[tblCityPopulationMap] ([ConfigurationID])
INCLUDE ([CityPopulationID])
END

IF NOT EXISTS(SELECT 1
FROM sys.indexes 
WHERE name='idx_tblFontMap' AND object_id = OBJECT_ID('[dbo].[tblFontMap]'))
BEGIN
CREATE NONCLUSTERED INDEX idx_tblFontMap
ON [dbo].[tblFontMap] ([ConfigurationID])
INCLUDE ([FontID])
END

IF NOT EXISTS(SELECT 1
FROM sys.indexes 
WHERE name='idx_tblWGContentMap' AND object_id = OBJECT_ID('[dbo].[tblWGContentMap]'))
BEGIN
CREATE NONCLUSTERED INDEX idx_tblWGContentMap
ON [dbo].[tblWGContentMap] ([ConfigurationID])
INCLUDE ([WGContentID])
END

