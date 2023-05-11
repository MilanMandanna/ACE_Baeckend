GO
DROP FUNCTION IF EXISTS [dbo].[config_tblRegion]
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Function returns the region data for given configuration id
-- =============================================
CREATE FUNCTION [dbo].[config_tblRegion]
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblRegionSpelling.*
	from tblRegionSpelling 
		inner join tblRegionSpellingMap on tblRegionSpellingMap.SpellingID = tblRegionSpelling.SpellingID
	where tblRegionSpellingMap.ConfigurationID = @configurationId
		and tblRegionSpellingMap.IsDeleted = 0
)
GO