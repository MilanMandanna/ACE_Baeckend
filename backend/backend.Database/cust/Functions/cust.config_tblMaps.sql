GO
DROP FUNCTION IF EXISTS config_tblMaps
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 10/10/2022
-- Description:	Function returns the Maps data for given configuration id
-- =============================================
CREATE FUNCTION config_tblMaps
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT M.* FROM cust.tblMaps M
	INNER JOIN cust.tblMapsMap MM ON M.MapID = MM.MapID
	WHERE MM.ConfigurationID = @configurationId AND MM.IsDeleted = 0
)
GO