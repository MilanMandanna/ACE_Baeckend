GO
DROP FUNCTION IF EXISTS [dbo].[config_tblASXiInset]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 19/05/2022
-- Description:	Function returns the inset data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblASXiInset
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblASXiInset.*
	from tblASXiInset 
		inner join tblASXiInsetMap on tblASXiInsetMap.ASXiInsetID = tblASXiInset.ASXiInsetID
	where tblASXiInsetMap.ConfigurationID = @configurationId
		and tblASXiInsetMap.IsDeleted = 0 
)
GO
