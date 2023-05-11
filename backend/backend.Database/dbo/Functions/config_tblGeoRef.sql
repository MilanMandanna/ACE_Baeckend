GO
DROP FUNCTION IF EXISTS [dbo].[config_tblGeoRef]
GO
/****** Object:  UserDefinedFunction [dbo].[config_tblGeoRef]    Script Date: 3/17/2022 5:24:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 21/03/2022
-- Description:	Function returns the Georef data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblGeoRef
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select
		tblGeoRef.*
	from tblGeoRef	
		inner join tblGeoRefMap on tblGeoRefMap.GeoRefID = tblGeoRef.ID
	where tblGeorefMap.ConfigurationID = @configurationId
		and tblgeorefmap.isdeleted = 0
)
