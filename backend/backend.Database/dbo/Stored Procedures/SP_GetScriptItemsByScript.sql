
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda	
-- Create date: 6/1/2022
-- Description:	get the scripttype based on configurationId and scrriptid
-- Sample: EXEC [dbo].[SP_GetScriptItemsByScript] 36,4
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScriptItemsByScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetScriptItemsByScript]
END
GO

CREATE PROCEDURE [dbo].[SP_GetScriptItemsByScript]
        @configurationId INT,
		@scriptId INT
       
AS

BEGIN

           select ISNULL(Nodes.item.value('(./@type)[1]','varchar(max)'),'') AS scriptType
            FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
            CROSS APPLY b.ScriptDefs.nodes('/script_defs/script/item') Nodes(item) WHERE ConfigurationID=@configurationId 
            AND ISNULL(Nodes.item.value('(../@id)[1]','varchar(max)'),'')=@scriptId
END
GO
