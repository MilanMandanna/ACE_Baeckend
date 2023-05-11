
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Get the forced languages based on configurationId and scriptId
-- Sample: EXEC [dbo].[SP_GetForcedLanguages] 36,4
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetForcedLanguages]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetForcedLanguages]
END
GO

CREATE PROCEDURE [dbo].[SP_GetForcedLanguages]
        @configurationId INT,
        @scriptId  INT
AS

BEGIN

               SELECT ISNULL(Nodes.item.value('(./@forced_langs)[1]','varchar(max)'),'') AS forced_lang 
               FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
               CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ISNULL(Nodes.item.value('(./@id)[1]','int'),'')= @scriptId AND ConfigurationID=@configurationId
END
GO

