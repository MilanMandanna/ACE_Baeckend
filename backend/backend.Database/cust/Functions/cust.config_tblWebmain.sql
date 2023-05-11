GO
DROP FUNCTION IF EXISTS cust.config_tblWebmain
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the Webmain data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblWebmain
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblWebMain.*
	from cust.tblWebMain 
		inner join cust.tblWebMainMap on cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
	where cust.tblWebMainMap.ConfigurationID = @configurationId
		and cust.tblWebMainMap.isDeleted = 0

)
GO
