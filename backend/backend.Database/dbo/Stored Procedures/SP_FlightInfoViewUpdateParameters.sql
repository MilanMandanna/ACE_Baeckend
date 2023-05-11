
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	This will update the scriptdef table with configurationId,infoname and infoitems
-- Sample: EXEC [dbo].[SP_FlightInfoViewUpdateParameters] 67 ,'Info Page 1_3D','eAltitude,eGroundSpeed,eHeading,eLatitude,eLocalTimeAtPresentPosition,eOutsideAirTemperature,eHeadwindTailwind'
-- =============================================
IF OBJECT_ID('[dbo].[SP_FlightInfoViewUpdateParameters]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_FlightInfoViewUpdateParameters]

END

GO

CREATE PROCEDURE [dbo].[SP_FlightInfoViewUpdateParameters]
                        @configurationId INT,
                        @infoName NVARCHAR(Max),
                        @infoItems NVARCHAR(Max)

AS

BEGIN        
         DECLARE @sql NVARCHAR(Max),@ScriptDefID Int,@updateKey Int
		 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		  SET @ScriptDefID = (SELECT cust.tblScriptDefsMap.ScriptDefID FROM cust.tblScriptDefsMap WHERE cust.tblScriptDefsMap.configurationId = @configurationId)
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@ScriptDefID,@updateKey out
         SET @sql=('UPDATE [cust].[tblScriptDefs]
             SET ScriptDefs.modify(''replace value of (/script_defs/infopages/infopage [@name=  "'+ @infoName +'"]/@infoitems)[1] 
             with  "'+ @infoItems + '" '')
             FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
             where  ConfigurationID = @configurationId AND b.ScriptDefID = @updateKey ')
		 EXEC sys.Sp_executesql @sql ,@params,@configurationId = @configurationId,@updateKey=@updateKey 
END

GO