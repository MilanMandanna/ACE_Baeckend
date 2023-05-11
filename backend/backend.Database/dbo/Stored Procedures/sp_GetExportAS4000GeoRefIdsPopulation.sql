GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsPopulation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsPopulation]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsPopulation
@configurationId INT
AS
BEGIN

SELECT 
	georefid,
	Population 
from tblCityPopulation
	inner join tblCityPopulationMap as cpmap on cpmap.CityPopulationID = tblCityPopulation.CityPopulationID
where
	cpmap.ConfigurationID = @configurationId and cpmap.IsDeleted=0

END

GO