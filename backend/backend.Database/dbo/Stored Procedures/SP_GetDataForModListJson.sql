SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 09/14/2022
-- Description:	Get data to build modlist JSON file
-- Sample EXEC [dbo].[SP_GetDataForModListJson] '1499,2956,1496,2953', 67, 'all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetDataForModListJson]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetDataForModListJson]
END
GO

CREATE PROCEDURE [dbo].[SP_GetDataForModListJson]
	@geoRefId NVARCHAR(MAX),
	@configurationId INT,
	@type NVARCHAR(50)
AS
BEGIN
	IF (@type = 'all')
	BEGIN
		SELECT GeoRef.GeoRefId, CoverageSegment.Lat1, CoverageSegment.Lon1, GeoRef.isInteractivePoi, GeoRef.AsxiCatTypeId, GeoRef.Description 
		FROM dbo.config_tblGeoRef(@configurationId) AS GeoRef
		OUTER APPLY dbo.config_tblCoverageSegment(@configurationId) AS CoverageSegment
		WHERE GeoRef.CustomChangeBitMask = 1 AND GeoRef.GeoRefId = CoverageSegment.GeoRefID

	END
	ELSE
	BEGIN
		SELECT GeoRef.GeoRefId, CoverageSegment.Lat1, CoverageSegment.Lon1, GeoRef.isInteractivePoi, GeoRef.AsxiCatTypeId, GeoRef.Description 
		FROM dbo.config_tblGeoRef(@configurationId) AS GeoRef
		OUTER APPLY dbo.config_tblCoverageSegment(@configurationId) AS CoverageSegment
		WHERE GeoRef.GeoRefId IN (SELECT * FROM STRING_SPLIT(@geoRefId, ',')) AND GeoRef.GeoRefId = CoverageSegment.GeoRefID
	END
END
GO