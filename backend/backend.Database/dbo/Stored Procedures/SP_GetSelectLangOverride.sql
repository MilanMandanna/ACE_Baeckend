
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	returns the row based on combined string
-- Sample: EXEC [dbo].[SP_GetSelectLangOverride] 67,2
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetSelectLangOverride]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_GetSelectLangOverride]

END

GO

CREATE PROCEDURE [dbo].[SP_GetSelectLangOverride]
                        @configurationId Int,
						@scriptId Int
                      
                       

AS

BEGIN

	     SELECT ISNULL(Nodes.item.value('(./@forced_langs)[1]','varchar(max)'),'') AS forced_lang
          FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID
          CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ISNULL(Nodes.item.value('(./@id)[1]','int'),'')= @scriptId AND ConfigurationID=@configurationId
			
END

GO