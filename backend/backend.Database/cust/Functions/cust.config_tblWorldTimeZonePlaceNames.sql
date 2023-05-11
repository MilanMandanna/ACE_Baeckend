GO
DROP FUNCTION IF EXISTS cust.config_tblWorldTimeZonePlaceNames
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the RLI data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblWorldTimeZonePlaceNames
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblWorldTimeZonePlaceNames.*
	from cust.tblWorldTimeZonePlaceNames 
		inner join cust.tblWorldTimeZonePlaceNamesMap on cust.tblWorldTimeZonePlaceNamesMap.PlaceNameID = cust.tblWorldTimeZonePlaceNames.PlaceNameID
	where cust.tblWorldTimeZonePlaceNamesMap.ConfigurationID = @configurationId
		and cust.tblWorldTimeZonePlaceNamesMap.isDeleted = 0

)
GO
