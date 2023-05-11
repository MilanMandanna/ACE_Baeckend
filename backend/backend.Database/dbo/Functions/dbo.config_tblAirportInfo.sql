GO
DROP FUNCTION IF EXISTS [dbo].[config_tblAirportInfo]
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 21/03/2022
-- Description:	Function returns the Airport data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblAirportInfo
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblAirportInfo.*
	from tblAirportInfo 
		inner join tblAirportInfoMap on tblAirportInfoMap.AirportInfoID = tblAirportInfo.AirportInfoID
	where tblAirportInfoMap.ConfigurationID = @configurationId
		and tblairportinfomap.isDeleted = 0
)
GO
