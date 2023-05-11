GO
DROP FUNCTION IF EXISTS cust.config_tblWorldMapPlaceNames
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
CREATE FUNCTION cust.config_tblWorldMapPlaceNames
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblWorldMapPlaceNames.*
	from cust.tblWorldMapPlaceNames 
		inner join cust.tblWorldMapPlaceNamesMap on cust.tblWorldMapPlaceNamesMap.PlaceNameID = cust.tblWorldMapPlaceNames.PlaceNameID
	where cust.tblWorldMapPlaceNamesMap.ConfigurationID = @configurationId
		and cust.tblWorldMapPlaceNamesMap.isDeleted = 0

)
GO
