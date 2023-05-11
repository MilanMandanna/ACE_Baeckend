GO
DROP FUNCTION IF EXISTS config_tblFlyOverAlert
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 10/10/2022
-- Description:	Function returns the FlyOverAlert data for given configuration id
-- =============================================
CREATE FUNCTION config_tblFlyOverAlert
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT F.* FROM cust.tblFlyOverAlert F
	INNER JOIN cust.tblFlyOverAlertMap FM ON F.FlyOverAlertID = FM.FlyOverAlertID
	WHERE FM.ConfigurationID = @configurationId AND FM.IsDeleted = 0
)
GO