GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportThalesPNameTriva]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportThalesPNameTriva]
END
GO
CREATE PROC sp_GetExportThalesPNameTriva
@configurationId INT
AS
BEGIN

select 
	GeoRefId,
	Elevation,
	Population,
	en as Lang_EN
from (
	select 
		tblspelling.GeoRefID,
		Elevation,
		Population,
		tblspelling.UnicodeStr,
		tblLanguages.[2LetterID_ASXi] as code
	from tblspelling
		inner join tblgeoref on tblgeoref.georefid = tblspelling.georefid
		inner join tblLanguages on tblLanguages.LanguageID = tblspelling.LanguageID
		inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
		inner join tblSpellingMap as smap on smap.SpellingID = tblspelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
		left join (
			select tblelevation.* from tblelevation inner join tblelevationmap on tblelevationmap.elevationid = tblelevation.id
			where tblelevationmap.configurationid = @configurationid and tblelevationmap.IsDeleted=0
		) as elevation on elevation.georefid = tblgeoref.georefid
		left join (
			select tblcitypopulation.* from tblCityPopulation inner join tblCityPopulationMap on tblCityPopulationMap.CityPopulationID = tblCityPopulation.CityPopulationID
			where tblCityPopulationMap.configurationid = @configurationid and tblCityPopulationMap.IsDeleted=0
		) as population on population.GeoRefID = tblgeoref.GeoRefId
	where
		tblgeoref.pntype = 1 and
		tblgeoref.georefid < 100000 and
		tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and
		grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0 and
		smap.ConfigurationID = @configurationId and smap.IsDeleted=0 and
		lmap.ConfigurationID = @configurationId and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ([en])
) as pivottable
order by GeoRefId

END

GO