SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/09/2022
-- Description:	this will fetch the landsat value
--EXEC [dbo].[SP_GetLandSatValue] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetLandSatValue]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetLandSatValue]
END
GO
CREATE PROCEDURE [dbo].[sp_GetLandSatValue]
			@configurationId INT
					
AS
BEGIN
	IF EXISTS (select 1 from cust.tblmaps MP INNER JOIN cust.tblmapsmap mm on MP.mapid = mm.mapid WHERE MM.CONFIGURATIONID = @configurationId)
	BEGIN
		SELECT ISNULL((MAP.V.value('(map_package)[1]', 'nvarchar(50)')), 'temnaturalvue') AS LandSat
		FROM cust.tblmaps MP INNER JOIN cust.tblmapsmap mm on MP.mapid = mm.mapid
		OUTER APPLY MP.mapitems.nodes('maps') AS MAP(V)
		WHERE MM.CONFIGURATIONID = @configurationId
	END
	ELSE
	BEGIN
		Select 'temnaturalvue' as LandSat
	END
END
GO