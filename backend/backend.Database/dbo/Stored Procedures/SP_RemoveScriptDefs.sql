
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date:  5/25/2022
-- Description:	This SP will update table scriptdefs based on configurationId and scriptId
--Sample: EXEC [dbo].[SP_RemoveScriptDefs] 36,4
-- =============================================

IF OBJECT_ID('[dbo].[SP_RemoveScriptDefs]','P') IS NOT NULL

BEGIN
        DROP PROC[dbo].[SP_RemoveScriptDefs]
END
GO

CREATE PROCEDURE [dbo].[SP_RemoveScriptDefs]
        @configurationId INT,
		@scriptId INT
       
AS

BEGIN       
            DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
		    DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
			--SET @scriptId = (SELECT cust.tblScriptDefsMap.ScriptDefID FROM cust.tblScriptDefsMap WHERE cust.tblScriptDefsMap.ConfigurationID =  @configurationId )
			SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
		  
      SET @sql =(' UPDATE [cust].[tblScriptDefs] 
            SET ScriptDefs.modify(''delete (/script_defs/script)[@id='+CAST(@scriptId as varchar)+']'')
            FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
            CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ISNULL(Nodes.item.value(''(./@id)[1]'',''int''),'''')= @scriptParamId AND 
            ConfigurationID= @configurationId AND b.ScriptDefID = @updateKey ' )
      EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey,@scriptParamId = @scriptId 
	
       
END
GO

