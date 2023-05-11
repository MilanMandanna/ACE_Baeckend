
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	get the maximum script id
-- Sample: EXEC [dbo].[SP_MaxScriptId] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_MaxScriptId]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_MaxScriptId]
END
GO

CREATE PROCEDURE [dbo].[SP_MaxScriptId]
        @configurationId INT
       
AS

BEGIN

                    SELECT MAX(ISNULL(Nodes.item.value('(./@id)[1]','int'),0)) AS maxScriptId 
                    FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c ON c.ScriptDefID = b.ScriptDefID
                    CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ConfigurationID  = @configurationId
END
GO
