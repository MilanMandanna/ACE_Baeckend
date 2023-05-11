GO

-- =============================================
-- Author:		Lakshmikanth
-- Create date: 18-Jul-2022
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetExportAS4000FourLetter]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetExportAS4000FourLetter]
END
GO
CREATE PROC SP_GetExportAS4000FourLetter
@configurationId INT
AS
BEGIN

select distinct
    airportinfo.*,
    '' as Country
    from tblairportinfo as airportinfo
    inner join tblairportinfomap map on map.airportinfoid = airportinfo.airportinfoid and map.configurationid = @configurationId
    ORDER BY airportinfo.FourLetId ASC
END

GO