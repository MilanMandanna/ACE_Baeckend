
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa,Brinda,Chindamada
-- Create date: 26/5/2022
-- Description:	Update the old language based on conditions
-- Sample: EXEC [dbo].[SP_UpdateOldLanguage] 36,4,'EN'
-- =============================================
IF OBJECT_ID('[dbo].[SP_UpdateOldLanguage]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_UpdateOldLanguage]

END

GO
CREATE PROCEDURE [dbo].[SP_UpdateOldLanguage]
                        @configurationId INT,
                        @scriptId INT,
						@twoLetterlanguageCodes NVARCHAR(100)
                       

AS

BEGIN        
         DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
		  DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
		   SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
         SET @sql=('UPDATE [cust].[tblScriptDefs]
                SET ScriptDefs.modify(''replace value of (/script_defs/script/@forced_langs)[../@id='+CAST(@scriptId as varchar)+'][1] with  "'+ @twoLetterlanguageCodes +'"'')
                FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ISNULL(Nodes.item.value(''(./@id)[1]'', ''int''), '''') =@scriptParamId AND ConfigurationID = @configurationId AND b.ScriptDefID = @updateKey ')
		 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey,@scriptParamId = @scriptId
		 
END

GO
