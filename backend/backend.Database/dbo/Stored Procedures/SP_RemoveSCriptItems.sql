
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa,Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	This SP will update the row in scriptdefs based on configurationId and scriptId
-- Sample: EXEC [dbo].[SP_RemoveSCriptItems] 67,8

--select * from [cust].[tblScriptDefsMap] where configurationId=67

-- =============================================
IF OBJECT_ID('[dbo].[SP_RemoveSCriptItems]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_RemoveSCriptItems]

END

GO

CREATE PROCEDURE [dbo].[SP_RemoveSCriptItems]
                        @configurationId INT,
                        @scriptId   INT
                       

AS

BEGIN        
            DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
		  DECLARE @params NVARCHAR(4000) = '@scriptParamId Int'
		  SELECT @scriptDefId=ScriptDefID FROM [cust].[tblScriptDefsMap] WHERE ConfigurationID=@configurationId
		  print @scriptDefId
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey OUT

      SET @sql=('UPDATE [cust].[tblScriptDefs] 
             SET ScriptDefs.modify(''delete (/script_defs/script[@id='+CAST(@scriptId as varchar)+ ']/item)'') 
             FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
             WHERE ConfigurationID = '+CAST(@configurationId AS varchar)+' AND b.ScriptDefID = '+CAST(@updateKey AS varchar)+' ')

print @updateKey

	  EXEC sys.Sp_executesql @sql,@params,@scriptParamId = @scriptId
END

GO
