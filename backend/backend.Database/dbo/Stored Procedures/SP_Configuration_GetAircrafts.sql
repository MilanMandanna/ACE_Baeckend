SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	returns list of aircrafts that has configuration mapping
-- Sample EXEC [dbo].[SP_Configuration_GetAircrafts] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetAircrafts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetAircrafts]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetAircrafts]
    @configurationId INT
AS
BEGIN
	SELECT DISTINCT * 
    FROM dbo.Aircraft 
    INNER JOIN dbo.tblAircraftConfigurationMapping ON dbo.tblAircraftConfigurationMapping.AircraftID = dbo.Aircraft.Id 
    INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblAircraftConfigurationMapping.ConfigurationDefinitionID
    WHERE dbo.tblConfigurations.ConfigurationID = @configurationId
END
GO