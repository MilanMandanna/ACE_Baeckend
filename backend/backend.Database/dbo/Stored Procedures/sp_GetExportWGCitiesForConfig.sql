GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGCitiesForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGCitiesForConfig]
END
GO
CREATE PROC sp_GetExportWGCitiesForConfig
@configurationId INT
AS
BEGIN

select 
	city_id,
	georefid
from tblwgwcities
	inner join tblwgwcitiesMap on tblwgwcitiesMap.CityID = tblwgwcities.city_id
where
	tblwgwcitiesMap.ConfigurationID = @configurationId
order by city_id

END

GO