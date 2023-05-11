GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXInfoGeoRefSpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXInfoGeoRefSpellings]
END
GO
CREATE PROC sp_GetExportASXInfoGeoRefSpellings
@configurationId INT,
@languageCodes NVARCHAR(MAX)
AS
BEGIN

DECLARE @sql NVARCHAR(MAX)
SET @sql = 'select 
	* 
from (
    select 
		tblgeoref.*, 
		tbllanguages.[2LetterID_ASXi] as code, 
		tblspelling.unicodestr as spelling,
		tblcitypopulation.population,
		tblelevation.elevation
    from tblgeoref
		inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
		inner join tblspelling on tblspelling.georefid = tblgeoref.georefid
		inner join tblspellingmap on tblspellingmap.spellingid = tblspelling.spellingid
		inner join tbllanguages on tbllanguages.languageid = tblspelling.languageid
		inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.id
		left join tblelevation on tblelevation.georefid = tblgeoref.georefid
		left join tblelevationmap on tblelevationmap.elevationid = tblelevation.id
		left join tblcitypopulation on tblcitypopulation.georefid = tblgeoref.georefid
		left join tblcitypopulationmap on tblcitypopulationmap.citypopulationid = tblcitypopulation.citypopulationid
    where tblgeorefmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tblgeorefmap.isDeleted=0 and
		tblspellingmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tblspellingmap.isDeleted=0 and
		tbllanguagesmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tbllanguagesmap.isDeleted=0 and
		((tblelevationmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tblelevationmap.isDeleted=0) or tblelevationmap.configurationid is null) and
		((tblcitypopulationmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tblcitypopulationmap.isDeleted=0) or tblcitypopulationmap.configurationid is null)
) as sourcetable
pivot(
    max(spelling)
    for code in (' + @languageCodes + ')
) as pivottable
order by georefid'

EXEC (@sql)

END

GO