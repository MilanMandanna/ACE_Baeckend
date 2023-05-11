
-- =============================================
-- Author:		Sathya
-- Create date: 14/07/2022
-- Description:	Returns url for timezone and venue next scripts url
-- =============================================
GO
IF OBJECT_ID('[dbo].[SP_getVenueNextArtifacts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_getVenueNextArtifacts]
END

GO
CREATE PROC SP_getVenueNextArtifacts
@configurationId INT
AS
BEGIN
SELECT ConfigurationComponentID,Path,ConfigurationComponentTypeID,Name FROM [dbo].[config_tblConfigurationComponents](@configurationId) WHERE ConfigurationComponentTypeID IN(4,10)
END