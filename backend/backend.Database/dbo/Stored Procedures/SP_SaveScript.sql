
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date:  5/25/2022
-- Description:	This will update the scriptdefs table based on condition 
-- Sample: EXEC [dbo].[SP_SaveScript] 67,2,'Tasdfsdfest1234dfa'
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_SaveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveScript]
        @configurationId INT,
		@scriptId INT,
		@scriptName  NVARCHAR(100)

       
AS

BEGIN
     
	DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
    DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
    SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
    EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
	print @updateKey
    SET @sql='UPDATE [cust].[tblScriptDefs]
	SET ScriptDefs.modify(''replace value of (/script_defs/script/@name)[../@id = '+CAST(@scriptId as varchar)+'][1] with "'+ @scriptName +'"'')
    FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
    CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ISNULL(Nodes.item.value(''(./@id)[1]'', ''int''), '''') = @scriptParamId AND ConfigurationID = @configurationId and b.ScriptDefID = @updateKey '

    EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey, @scriptParamId = @scriptId
END
GO

