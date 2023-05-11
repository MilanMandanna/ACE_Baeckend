SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Utility SP to get the max of configuration and configuration defiition
-- Sample EXEC [dbo].[SP_Configuration_Utility] 'configuration'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_Utility]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_Utility]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_Utility]
	@type VARCHAR(Max)
AS
BEGIN
	IF(@type = 'configuration')
	BEGIN
        SELECT MAX(ConfigurationID) FROM dbo.tblConfigurations;
    END
    ELSE IF (@type = 'configuration definition')
    BEGIN
       SELECT MAX(ConfigurationDefinitionID) FROM dbo.tblConfigurationDefinitions;
    END
END
GO