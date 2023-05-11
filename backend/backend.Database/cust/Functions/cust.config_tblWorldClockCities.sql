GO
DROP FUNCTION IF EXISTS cust.config_tblWorldClockCities
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the world clock city data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblWorldClockCities
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblWorldClockCities.*
	from tblWorldClockCities 
		inner join tblWorldClockCitiesMap on tblWorldClockCitiesMap.WorldClockCityID = tblWorldClockCities.WorldClockCityID
	where tblWorldClockCitiesMap.ConfigurationID = @configurationId
		and tblWorldClockCitiesMap.isDeleted = 0
)
GO
