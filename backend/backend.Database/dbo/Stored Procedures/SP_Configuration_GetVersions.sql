SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	returns list of configurations for a given configuration definition
-- Sample EXEC [dbo].[SP_Configuration_GetVersions] 3, 'locked'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetVersions]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetVersions]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetVersions]
	@configurationDefinitionID INT,
    @type VARCHAR(Max)
AS
BEGIN
	IF(@type = 'all')
	BEGIN
       SELECT C.* ,p.Name as PlatFormName,ps.Name as ProductName, a.TailNumber as TailNumber
        FROM dbo.tblConfigurations C
        LEFT JOIN dbo.tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        LEFT JOIN tblplatformconfigurationmapping pcm ON Cd.ConfigurationDefinitionID = pcm.ConfigurationDefinitionID
        LEFT JOIN tblproductconfigurationmapping prcm ON Cd.ConfigurationDefinitionID = prcm.ConfigurationDefinitionID
        LEFT JOIN tblPlatforms p ON pcm.PlatformID = p.PlatformID
        LEFT JOIN tblProducts ps ON prcm.ProductID = ps.ProductID
        left join tblAircraftConfigurationMapping acm on acm.ConfigurationDefinitionID = cd.ConfigurationDefinitionID
		 LEFT JOIN Aircraft a ON acm.AircraftID =a.Id
        WHERE C.ConfigurationDefinitionID = @configurationDefinitionID ORDER BY C.Version DESC
    END
    ELSE IF (@type = 'locked')
    BEGIN
        SELECT C.* ,p.Name as PlatFormName,ps.Name as ProductName,a.TailNumber as TailNumber
        FROM dbo.tblConfigurations C
        LEFT JOIN dbo.tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        LEFT JOIN tblplatformconfigurationmapping pcm ON Cd.ConfigurationDefinitionID = pcm.ConfigurationDefinitionID
        LEFT JOIN tblproductconfigurationmapping prcm ON Cd.ConfigurationDefinitionID = prcm.ConfigurationDefinitionID
        LEFT JOIN tblPlatforms p ON pcm.PlatformID = p.PlatformID 
        LEFT JOIN tblProducts ps ON prcm.ProductID = ps.ProductID
        left join tblAircraftConfigurationMapping acm on acm.ConfigurationDefinitionID = cd.ConfigurationDefinitionID
		 LEFT JOIN Aircraft a ON acm.AircraftID =a.Id
        WHERE C.ConfigurationDefinitionID = @configurationDefinitionID AND C.Locked=1 ORDER BY C.Version DESC
    END
END
GO