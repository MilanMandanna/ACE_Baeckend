
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	get the name and display name from table getscriptitemtypes
-- Sample: EXEC [dbo].[SP_GetScriptItemTypes] 112
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScriptItemTypes]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetScriptItemTypes]
END
GO

CREATE PROCEDURE [dbo].[SP_GetScriptItemTypes]
       
       @configurationID INT
AS

BEGIN

	 DECLARE @featuresetID INT
	   SET @featuresetID =( SELECT DISTINCT dbo.tblFeatureSet.FeatureSetID 
         FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
         INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
         AND dbo.tblConfigurations.ConfigurationID = @configurationId)

       SELECT *  
               FROM   
             (SELECT dbo.tblFeatureSet.Value as Name  
               FROM dbo.tblFeatureSet  
               WHERE dbo.tblFeatureSet.Name = 'CustomConfig-OverheadAutoplay-ScriptList'  AND dbo.tblFeatureSet.FeatureSetID = @featuresetID) as Nametable ,
                (SELECT dbo.tblFeatureSet.Value as DisplayName  
               FROM dbo.tblFeatureSet  
               WHERE dbo.tblFeatureSet.Name = 'CustomConfig-OverheadAutoplay-ScriptDisplayList'  AND dbo.tblFeatureSet.FeatureSetID = @featuresetID) as DisplayNameTable
END
GO


