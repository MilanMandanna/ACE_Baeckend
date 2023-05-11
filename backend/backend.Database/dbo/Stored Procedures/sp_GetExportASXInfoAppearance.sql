GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXInfoAppearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXInfoAppearance]
END
GO
CREATE PROC sp_GetExportASXInfoAppearance
@configurationId INT
AS
BEGIN

select
	*
from(
    select 
		tblgeoref.georefid,
		tblappearance.ResolutionMpp as resolution,
		cast(tblAppearance.exclude as int) as exclude
    from tblgeoref
		inner join tblappearance on tblappearance.georefid = tblgeoref.georefid
		inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
		inner join tblappearancemap on tblappearancemap.appearanceid = tblappearance.appearanceid
    where 
		tblgeorefmap.configurationid = @configurationId and tblgeorefmap.IsDeleted=0 and
		tblappearancemap.configurationid = @configurationId and tblappearancemap.isDeleted=0
) as sourcetable
pivot(
    max(exclude)
    for resolution in ([15360], [7680], [3840], [1920], [960], [480], [240], [120], [60], [30], [15])
) as pivottable
order by georefid

END

GO