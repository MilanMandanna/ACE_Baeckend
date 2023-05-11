SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author Abhishek Narasimha Prasad
-- Create date: 02/03/2022
-- Description:	Updates Autolock or Autodeploy columns in Configdefinition table
-- Sample EXEC [dbo].[SP_Config_UpdateAutoLockorAutoDeploy] 18, 1, 'AutoLock'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Config_UpdateAutoLockorAutoDeploy]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Config_UpdateAutoLockorAutoDeploy]
END
GO

CREATE PROCEDURE [dbo].[SP_Config_UpdateAutoLockorAutoDeploy]
	@configurationDefinitionId INT,
	@autoLock INT,
	@autoDeploy INT,
	@autoMerge INT

AS
BEGIN
	UPDATE dbo.tblConfigurationDefinitions
	SET AutoLock = @autoLock, AutoDeploy = @autoDeploy, AutoMerge = @autoMerge
	WHERE ConfigurationDefinitionID = @configurationDefinitionId
END
GO
