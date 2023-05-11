GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXInfoTimezoneStrips]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXInfoTimezoneStrips]
END
GO
CREATE PROC sp_GetExportASXInfoTimezoneStrips
@configurationId INT
AS
BEGIN
select
	tblgeoref.georefid,
	tblgeoref.tzstripid as tzstripid
from tblgeoref
	inner join tbltimezonestrip on tbltimezonestrip.tzstripid = tblgeoref.tzstripid
	inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
	inner join tbltimezonestripmap on tbltimezonestripmap.timezonestripid = tbltimezonestrip.tzstripid
where
	tblgeorefmap.configurationid = @configurationId and tblgeorefmap.isDeleted=0
	and tbltimezonestripmap.configurationid = @configurationId and tbltimezonestripmap.isDeleted=0
order by tblgeoref.georefid
END

GO