SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/20/2023
-- Description:	Get all available installation types and outputtypes
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes] 'installation'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes]
@type NVARCHAR(150)
AS
BEGIN
	IF (@type = 'installation')
	BEGIN
		SELECT * FROM InstallationTypes
	END
	ELSE IF (@type = 'outputtypes')
	BEGIN
		SELECT * FROM tblOutputTypes
	END
END
GO