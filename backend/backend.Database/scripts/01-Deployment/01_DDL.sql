IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ImageGuid'
          AND Object_ID = Object_ID(N'DBO.tblImage'))
BEGIN
   ALTER TABLE tblImage ADD ImageGuid NVARCHAR(500)
END

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

IF EXISTS(SELECT 1 FROM sys.columns 
    WHERE Name = N'Path'
    AND Object_ID = Object_ID(N'DBO.tblConfigurationComponents'))
BEGIN
   ALTER TABLE tblConfigurationComponents ALTER COLUMN Path NVARCHAR(MAX)
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
    WHERE Name = N'ErrorLog'
    AND Object_ID = Object_ID(N'DBO.tblConfigurationComponents'))
BEGIN
   ALTER TABLE tblConfigurationComponents ADD ErrorLog NVARCHAR(MAX)
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
    WHERE Name = N'LastModifiedDate'
    AND Object_ID = Object_ID(N'DBO.tblConfigurationComponentsMap'))
BEGIN
   ALTER TABLE tblConfigurationComponentsMap ADD LastModifiedDate DATETIME
END



GO
PRINT N'Creating Table [dbo].[tblTempPlacNamesNationalFile]...';

IF NOT  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tblTempPlacNamesNationalFile]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) BEGIN
CREATE TABLE [dbo].[tblTempPlacNamesNationalFile](

	[Id]					INT 			NOT NULL IDENTITY(1,1), 
	[CityName]				NVARCHAR(250)	NULL, 
	[Lat]					NVARCHAR(50)	NULL, 
	[Long]					NVARCHAR(50)	NULL,
	[BGNFilter]				NVARCHAR(50)	NULL,
)
END
GO
PRINT N'Creating Table [dbo].[tblTempCityInfo]...';


IF NOT  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tblTempCityInfo]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) BEGIN
CREATE TABLE [dbo].[tblTempCityInfo](

	[Id]					INT 			NOT NULL IDENTITY(1,1), 
	[City]					NVARCHAR(250)	NULL, 
	[Population]			NVARCHAR(250)	NULL
)
END
GO

--Prioriity column is part of GeoRef, we shouldnt have one here.

 IF NOT EXISTS(SELECT 1 FROM sys.columns 
           WHERE Name = N'Priority'
           AND Object_ID = Object_ID(N'dbo.tblAppearance'))
 BEGIN
 ALTER TABLE tblAppearance ADD Priority INT DEFAULT 0
 END