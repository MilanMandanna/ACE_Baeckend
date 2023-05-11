GO
DROP FUNCTION IF EXISTS cust.config_tblMakkah
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the Makkah data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblMakkah
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblMakkah.*
	from cust.tblMakkah 
		inner join cust.tblMakkahMap on cust.tblMakkahMap.MakkahID = cust.tblMakkah.MakkahID
	where cust.tblMakkahMap.ConfigurationID = @configurationId
		and cust.tblMakkahMap.isDeleted = 0

)
GO
