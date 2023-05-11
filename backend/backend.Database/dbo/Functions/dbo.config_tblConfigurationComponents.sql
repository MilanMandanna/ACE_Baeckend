GO
DROP FUNCTION IF EXISTS [dbo].[config_tblConfigurationComponents]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 21/03/2022
-- Description:	Function returns the tConfiguration Components data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblConfigurationComponents
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select 
		tblConfigurationComponents.*
	from tblConfigurationComponents 
		inner join tblConfigurationComponentsMap on tblConfigurationComponentsMap.ConfigurationComponentID = tblConfigurationComponents.ConfigurationComponentID
	where tblConfigurationComponentsMap.ConfigurationID = @configurationId
		and tblConfigurationComponentsMap.IsDeleted = 0
)
GO
