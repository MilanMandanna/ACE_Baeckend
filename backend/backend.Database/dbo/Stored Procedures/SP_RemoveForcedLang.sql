
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 26/5/2022
-- Description:	Removes  the forced language settings
-- Sample: EXEC [dbo].[SP_RemoveForcedLang] 36,4
-- =============================================
IF OBJECT_ID('[dbo].[SP_RemoveForcedLang]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_RemoveForcedLang]

END

GO

CREATE PROCEDURE [dbo].[SP_RemoveForcedLang]
                        @configurationId INT,
                        @ScriptId NVARCHAR(100)
                       

AS

BEGIN        
         DECLARE @sql NVARCHAR(Max),@scriptDefId Int,@updateKey Int
		 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		  SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
         SET @sql=('UPDATE [cust].[tblScriptDefs]  SET ScriptDefs.modify(''delete (/script_defs/script/@forced_langs)[../@id='+@scriptId+'][1]'') 
			FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
			CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE 
			  ConfigurationID =  @configurationId  AND b.ScriptDefID = @updateKey' )
		  EXEC sys.Sp_executesql @sql ,@params,@configurationId = @configurationId,@updateKey=@updateKey
END

GO
