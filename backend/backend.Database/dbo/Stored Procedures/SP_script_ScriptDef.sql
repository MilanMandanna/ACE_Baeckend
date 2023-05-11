
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	update scriptdef based on configurationid and xmlScript
-- Sample: EXEC [dbo].[SP_script_ScriptDef] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_ScriptDef]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_script_ScriptDef]
END
GO

CREATE PROCEDURE [dbo].[SP_script_ScriptDef]
        @configurationId INT,
		@xmlScript NVARCHAR(100)
       
AS

BEGIN
       DECLARE @sql NVARCHAR(Max),@scriptDefId Int,@updateKey Int, @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
	   SET @scriptDefId = (SELECT cust.tblScriptDefsMap.ScriptDefID FROM cust.tblScriptDefsMap WHERE cust.tblScriptDefsMap.configurationId = @configurationId)
		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
       SET @sql=('UPDATE [cust].[tblScriptDefs] 
                 SET ScriptDefs.modify(''insert '+ @xmlScript+'  as last into (/script_defs)[1]'')
                  FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                   CROSS APPLY b.ScriptDefs.nodes(''/script_defs'') Nodes(item) WHERE ConfigurationID =  @configurationId AND b.ScriptDefID = @updateKey')
		EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
END
GO


