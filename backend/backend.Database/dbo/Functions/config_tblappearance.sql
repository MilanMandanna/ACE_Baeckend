GO
DROP FUNCTION IF EXISTS [dbo].[config_tblAppearance]
GO
/****** Object:  UserDefinedFunction [dbo].[config_tblAppearance]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 12/12/2022
-- Description:	Function returns the tblAppearance data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblAppearance
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblAppearance.*
	from tblAppearance 
		inner join tblAppearanceMap on tblAppearanceMap.AppearanceID = tblAppearance.AppearanceID
	where tblAppearanceMap.ConfigurationID = @configurationId
		and tblAppearanceMap.isDeleted = 0
)
GO