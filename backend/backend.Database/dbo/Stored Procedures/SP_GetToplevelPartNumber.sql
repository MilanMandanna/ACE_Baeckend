
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================2
-- Author:		Abhishek PM
-- Create date:13 /1/2023
-- Description:	Get the partnumber collection id
-- Sample EXEC [dbo].[SP_GetToplevelPartNumber] 5037
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetToplevelPartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetToplevelPartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_GetToplevelPartNumber]
    @configurationDefnitionID int 
	
    
AS
BEGIN
	
    SELECT Products.TopLevelPartnumber from dbo.tblProducts AS Products 
        INNER JOIN dbo.tblProductConfigurationMapping AS Product 
        ON  Products.ProductID = Product.ProductID Where Product.ConfigurationDefinitionID = @configurationDefnitionID

END
GO