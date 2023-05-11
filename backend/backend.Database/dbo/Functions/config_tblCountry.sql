SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
drop function if exists dbo.config_tblCountry

GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 21/03/2022
-- Description:	Function returns the country data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblCountry
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblCountry.*
	from tblCountry 
		inner join tblCountryMap on tblCountryMap.CountryID = tblCountry.ID
	where tblCountryMap.ConfigurationID = @configurationId
		and tblCountryMap.IsDeleted = 0
)
GO
