
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================2
-- Author:		Abhishek PM
-- Create date:13 /1/2023
-- Description:	Get the partnumber collection id
-- Sample EXEC [dbo].[SP_GetPartNumberCollectionId] 5080
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetPartNumberCollectionId]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPartNumberCollectionId]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPartNumberCollectionId]
    @ConfigurationDefinitionId int 
	
    
AS
BEGIN
	DECLARE @configurationDefinitionParentID INT
    Set @configurationDefinitionParentID = (select configurationDefinitionParentID from tblConfigurationDefinitions where configurationDefinitionID = @configurationDefinitionID)
    select Distinct pn.PartNumberCollectionID from tblPartNumber as pn  inner join tblOutputTypes  
	as ot on pn.PartNumberCollectionID =ot.PartNumberCollectionID  inner join  tblConfigurationDefinitions as tc
	on  tc.OutputTypeID = ot.OutputTypeID where tc.ConfigurationDefinitionID = @configurationDefinitionParentID

END
GO