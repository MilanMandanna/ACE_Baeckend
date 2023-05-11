
-- =============================================
-- Author:		Sathya
-- Create date: 7/27/2022
-- Description:	Returns all componenent types and its config path for a given config id
-- =============================================
GO
IF OBJECT_ID('[dbo].[SP_getConfigComponentsArtifacts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_getConfigComponentsArtifacts]
END
GO

CREATE PROC [dbo].[SP_getConfigComponentsArtifacts]  
@configurationId INT  
AS  
BEGIN  
SELECT ConfigurationComponentID,Path,ConfigurationComponentTypeID,Name FROM [dbo].[config_tblConfigurationComponents](@configurationId)  
END
GO