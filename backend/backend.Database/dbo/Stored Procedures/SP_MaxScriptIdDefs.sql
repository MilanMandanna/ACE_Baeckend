
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Update max script Id based on configurationId and xmlScript
-- Sample: EXEC [dbo].[SP_MaxScriptIdDefs] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_MaxScriptIdDefs]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_MaxScriptIdDefs]
END
GO

CREATE PROCEDURE [dbo].[SP_MaxScriptIdDefs]
        @configurationId INT,
		@xmlScript  NVARCHAR(100)
		
		
		       
AS

BEGIN
            DECLARE @sql NVARCHAR(Max),@scriptDefId Int,@updateKey Int
			 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
			     SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
			  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
            SET @sql=('update [cust].[tblscriptdefs] 
                    set scriptdefs.modify(''insert  '+@xmlScript +'  as last into (/script_defs)[1]'') 
                    from cust.tblscriptdefs b inner join[cust].tblscriptdefsmap c on c.scriptdefid = b.scriptdefid 
                   cross apply b.scriptdefs.nodes(''/script_defs'') nodes(item) where configurationid = @configurationid AND  b.ScriptDefID = @updateKey')
			 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey 
END
GO

