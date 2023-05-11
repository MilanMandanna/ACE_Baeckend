GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns geo ref id for not us
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsPnameTriviaNonUS]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsPnameTriviaNonUS]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsPnameTriviaNonUS
@configurationId INT
AS
BEGIN

SELECT DISTINCT
  Gr.GeoRefId, 
  (Sp.UnicodeStr + ', ' + tblcountryspelling.CountryName) as Name, 
  Gr.CountryId, 
  null as StateCode, 
  Area, 
  Elevation, 
  Population
FROM tblGeoRef AS Gr
  inner join tblgeorefmap on tblgeorefmap.georefid = gr.id
  inner join tblspelling as sp on sp.georefid = gr.georefid
  inner join tblspellingmap on tblspellingmap.spellingid = sp.spellingid
  inner join tblcountryspelling on tblcountryspelling.CountryID = gr.countryid
  inner join tblcountryspellingmap as csmap on csmap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
  left join tblArea on tblArea.GeoRefID = Gr.GeoRefID
  left join tblAreaMap as amap on amap.AreaID = tblArea.AreaID
  left join tblElevation on tblElevation.GeoRefID = Gr.GeoRefId
  left join tblElevationMap as emap on emap.ElevationID = tblElevation.ID
  left join tblCityPopulation on tblCityPopulation.GeoRefID = gr.GeoRefId
  left join tblCityPopulationMap as cmap on cmap.CityPopulationID = tblCityPopulation.CityPopulationID
WHERE 
  tblgeorefmap.configurationid = @configurationId   and tblgeorefmap.isDeleted=0
  and tblspellingmap.configurationid = @configurationId and tblspellingmap.IsDeleted=0
  and csmap.configurationid = @configurationId and csmap.IsDeleted=0
  and Gr.GeoRefId IN (SELECT GeoRefId FROM tblGeoRef WHERE GeoRefId < 100000) 
  AND Sp.LanguageId = 1 
  AND Gr.CountryId != 251 
  AND Gr.PnType = 1
  and tblcountryspelling.LanguageID = 1
  and ((amap.ConfigurationID = @configurationId and amap.IsDeleted=0) or amap.ConfigurationID is null)
  and ((emap.ConfigurationID = @configurationId and emap.IsDeleted=0)or emap.ConfigurationID is null )
  and ((cmap.ConfigurationID = @configurationId and cmap.IsDeleted=0) or cmap.ConfigurationID is null )
order by gr.GeoRefId

END

GO