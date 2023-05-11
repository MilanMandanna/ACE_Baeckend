
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	get the script based on configurationId
-- Sample: EXEC [dbo].[SP_GetScripts] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScripts]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetScripts]
END
GO

CREATE PROCEDURE [dbo].[SP_GetScripts]
        @configurationId INT
       
AS

BEGIN

                  SELECT ISNULL(Nodes.item.value('(./@name)[1]','varchar(max)'),'') AS name ,
                  ISNULL(Nodes.item.value('(./@id)[1]','int'),'') AS id 
                  FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                  CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ConfigurationID  = @configurationId
END
GO
