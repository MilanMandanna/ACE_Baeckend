
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda Chindamada Aiyappa
-- Create date: 08/18/2022
-- Description:	Get the default part number
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_DefaultPartNumber] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_DefaultPartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_DefaultPartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_DefaultPartNumber]
    @ConfigurationDefinitionId int 
	
    
AS
BEGIN
	
	select pa.PartNumberID,pa.Description,pa.DefaultPartNumber from tblConfigurationDefinitionPartNumber t INNER JOIN tblPartNumber pa ON t.PartNumberID = pa.PartNumberID where t.ConfigurationDefinitionID = @configurationDefinitionId
END
GO