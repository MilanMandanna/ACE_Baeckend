GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns spelling of Destination for configurationId
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportDataAS4000DestinationSpelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportDataAS4000DestinationSpelling]
END
GO
CREATE PROC sp_GetExportDataAS4000DestinationSpelling
@configurationId INT
AS
BEGIN

SELECT 
	tblAirportInfo.FourLetId, 
	tblSpelling.languageid as LangId, 
	substring(tblSpelling.unicodestr, 1, 50) as DestinationSpelling, 
	1002 as CabinWXMapFontID, 
	10308 as FontId
from tblAirportInfo 
	inner join tblairportinfomap as apmap on apmap.AirportInfoID = tblAirportInfo.AirportInfoID
	INNER JOIN tblSpelling ON tblAirportInfo.georefid = tblSpelling.georefid
	inner join tblspellingmap as spmap on spmap.SpellingID = tblspelling.SpellingID
WHERE 
	tblSpelling.unicodestr is not null
	and apmap.ConfigurationID = @configurationId and apmap.IsDeleted=0
	and spmap.ConfigurationID = @configurationId and spmap.IsDeleted=0
order by fourletid

END

GO