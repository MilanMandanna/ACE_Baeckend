SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date: 01/31/2023
-- Description:	copies the top level partnumber
-- =============================================

IF OBJECT_ID('[dbo].[SP_SetTopLevelPartnumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SetTopLevelPartnumber]
END
GO

CREATE PROCEDURE [dbo].[SP_SetTopLevelPartnumber]
    @copyFileName VARCHAR(15),
	@configurationDefinitionID INT 
AS
BEGIN
      update tblproducts SET TopLevelPartnumber = @copyFileName from tblproducts   inner join tblproductconfigurationmapping on tblproducts.productid = tblproductconfigurationmapping.productid 
      inner join tblconfigurationdefinitions on tblproductconfigurationmapping.configurationdefinitionid = tblconfigurationdefinitions.ConfigurationDefinitionParentID 
      where tblConfigurationDefinitions.ConfigurationDefinitionID = @configurationDefinitionID
END
GO