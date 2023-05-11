GO
DROP FUNCTION IF EXISTS cust.config_tblRLI
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
CREATE FUNCTION cust.config_tblRLI
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblRli.*
	from cust.tblRli 
		inner join cust.tblRLIMap on cust.tblRLIMap.RLIID = cust.tblRli.RLIID
	where cust.tblRLIMap.ConfigurationID = @configurationId
		and cust.tblRLIMap.isDeleted = 0

)
GO
