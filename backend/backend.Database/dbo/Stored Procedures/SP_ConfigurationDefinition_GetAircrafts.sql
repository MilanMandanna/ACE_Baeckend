SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Returns the list of aircraft that have configuration definitions that are not associated to a fleet that are accessible to the given user for the specified operator.
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetAircrafts] '4dbed025-b15f-4760-b925-34076d13a10a'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetAircrafts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetAircrafts]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetAircrafts]
	@userId UNIQUEIDENTIFIER,
    @operatorId UNIQUEIDENTIFIER

AS
BEGIN
	 select 
    distinct aircraft.*, 
    tblconfigurationdefinitions.ConfigurationDefinitionID, 
    Aircraft.SerialNumber, 
    Aircraft.TailNumber,
    tblConfigurations.ConfigurationID
    from aircraft inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id 
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1 
       inner join tblConfigurations on tblconfigurationdefinitions.ConfigurationDefinitionID=tblConfigurations.ConfigurationDefinitionID and locked!=1
    inner join operator on aircraft.operatorid=Operator.Id
       where Aircraft.OperatorId= @operatorId 

END
GO