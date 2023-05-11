GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSESpellingsTrivia]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSESpellingsTrivia]
END
GO
CREATE PROC sp_GetExportCESHTSESpellingsTrivia
@configurationId INT,
@languages NVARCHAR(MAX)

AS
BEGIN
DECLARE @sql NVARCHAR(MAX)
SET @sql ='select 
	*
from (
    select 
		tblspelling.GeoRefID,
		edata.Elevation,
		pdata.Population,
		tblspelling.UnicodeStr,
		tblLanguages.[2LetterID_ASXi] as code
    from tblspelling
		inner join tblgeoref on tblgeoref.georefid = tblspelling.georefid
		inner join tblLanguages on tblLanguages.LanguageID = tblspelling.LanguageID
		inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
		inner join tblSpellingMap as smap on smap.SpellingID = tblspelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
		left join (
			select GeoRefId, Population from tblCityPopulation inner join tblCityPopulationMap on tblCityPopulationMap.CityPopulationID = tblCityPopulation.CityPopulationID
			where tblCityPopulationMap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and tblCityPopulationMap.IsDeleted=0
		) pdata on pdata.GeoRefID = tblSpelling.GeoRefID
		left join (
			select georefid, elevation from tblElevation inner join tblElevationMap on tblElevationMap.ElevationID = tblElevation.Elevation
			where tblElevationMap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and tblElevationMap.IsDeleted=0
		) edata on edata.GeoRefID = tblSpelling.GeoRefID

    where
		tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and
		tblgeoref.pntype = 1 and
		tblgeoref.georefid < 100000 and
		grmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and grmap.IsDeleted=0 and
		smap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and smap.IsDeleted=0 and
		lmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ('+@languages+')
) as pivottable
order by GeoRefId'

EXECUTE sp_executesql @sql;

END

GO