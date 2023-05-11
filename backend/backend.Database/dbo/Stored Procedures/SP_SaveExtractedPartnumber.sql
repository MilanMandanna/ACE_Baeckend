SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date: 01/31/2023
-- Description:	saves the extracted partnumbers
-- EXEC [dbo].[SP_SaveExtractedPartnumber] 5080,11,'072-4600-852853'
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveExtractedPartnumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SaveExtractedPartnumber]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveExtractedPartnumber]
   @configurationDefinitionID INT,
   @partNumberID INT,
   @partNumber NVARCHAR(255)
AS

BEGIN
    DECLARE @configurationDefinitionParentID INT
    Set @configurationDefinitionParentID = (select configurationDefinitionParentID from tblConfigurationDefinitions where configurationDefinitionID = @configurationDefinitionID)
    IF NOT EXISTS(select 1 from tblConfigurationDefinitionPartNumber where configurationdefinitionid = @configurationDefinitionParentID AND partNumberID = @partNumberID)
	BEGIN
	INSERT INTO tblConfigurationDefinitionPartNumber (ConfigurationDefinitionID, PartNumberID,Value) VALUES (@configurationDefinitionParentID,@partNumberID, @partNumber)
	END
	ELSE
	BEGIN
    Update tblConfigurationDefinitionPartNumber SET Value = @partNumber where ConfigurationDefinitionID  = @configurationDefinitionParentID AND PartNumberID = @partNumberID
	END
END

GO