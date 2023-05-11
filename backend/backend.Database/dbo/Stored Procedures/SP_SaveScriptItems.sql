
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda	
-- Create date: 6/1/2022
-- Description:	this sp will update the row in scriptdefs based on configurationid,strxmlitem and scriptid
--Sample: EXEC [dbo].[SP_SaveScriptItems] 1,'ENGLISH',1
-- =============================================
	-- =============================================
IF OBJECT_ID('[dbo].[SP_SaveScriptItems]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_SaveScriptItems]

END

GO

CREATE PROCEDURE [dbo].[SP_SaveScriptItems]
                        @configurationId INT,
						@strXmlitem NVARCHAR(MAX),
						@scriptId INT
                      
                       

AS

BEGIN 
            DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId Int
			    DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
				SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
    EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
      SET @sql='UPDATE [cust].[tblScriptDefs] 
            SET ScriptDefs.modify(''insert (' + @strXmlitem + ' )into 
             (/script_defs/script)[@id='+CAST(@scriptId as varchar)+'][1]'') 
            FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
            CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ConfigurationID =  @configurationId AND  b.ScriptDefID = @updateKey '
	  EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey, @scriptParamId = @scriptId
END

GO
