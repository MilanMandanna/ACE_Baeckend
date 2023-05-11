GO
DROP FUNCTION IF EXISTS cust.config_tblMenu
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the Menu data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblMenu
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblMenu.*
	from tblMenu 
		inner join tblMenuMap on tblMenuMap.MenuID = tblMenu.MenuID
	where tblMenuMap.ConfigurationID = @configurationId
		and tblMenuMap.isDeleted = 0
)
GO
