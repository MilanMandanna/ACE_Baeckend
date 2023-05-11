
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	This query returns DownloadPreference from InstallationTypes table based on given condition and installationtypeID
-- Sample: EXEC [dbo].[SP_GetDownloadPreferencesOfType] '23825E21-652E-482E-8AB0-870FD67BA94B'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetDownloadPreferencesOfType]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetDownloadPreferencesOfType]
END
GO

CREATE PROCEDURE [dbo].[SP_GetDownloadPreferencesOfType]
        @installationtypeID uniqueidentifier
       
AS

BEGIN

               Select DownloadPreference.* from  dbo.InstallationTypes InstallType 
               INNER JOIN dbo.tblPlatforms on  dbo.tblPlatforms.InstallationTypeID = InstallType.ID 
               INNER JOIN dbo.tblPlatformConfigurationMapping on dbo.tblPlatformConfigurationMapping.PlatformID = tblPlatforms.PlatformID 
               INNER JOIN dbo.tblConfigurationDefinitions  on tblConfigurationDefinitions.ConfigurationDefinitionID = tblPlatformConfigurationMapping.ConfigurationDefinitionID 
               INNER JOIN dbo.tblAircraftConfigurationMapping on dbo.tblAircraftConfigurationMapping.ConfigurationDefinitionID = tblConfigurationDefinitions.ConfigurationDefinitionID 
               INNER JOIN dbo.Aircraft on dbo.Aircraft.Id = tblAircraftConfigurationMapping.AircraftID INNER JOIN dbo.DownloadPreferenceAssignment 
               ON dbo.DownloadPreferenceAssignment.AircraftId = dbo.Aircraft.Id 
                INNER JOIN dbo.DownloadPreference on dbo.DownloadPreference.Id = dbo.DownloadPreferenceAssignment.DownloadPreferenceID 
                where InstallType.ID =  @installationtypeID
END
GO


