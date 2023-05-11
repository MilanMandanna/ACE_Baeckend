SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	checks if a configuration exist for given configuration definition
-- Sample EXEC [dbo].[SP_Configuration_GetIfExist] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetIfExist]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetIfExist]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetIfExist]
	@configurationDefinitionID INT
AS
BEGIN
    SELECT dbo.tblConfigurations.ConfigurationID
    FROM dbo.tblConfigurations
    WHERE dbo.tblConfigurations.ConfigurationDefinitionID = @configurationDefinitionID
END
GO