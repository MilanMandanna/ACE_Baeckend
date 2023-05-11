
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date:6/1/2022
-- Description:	this will return xmlitem based on condition from cust.tblScriptdefs
-- Sample: EXEC [dbo].[SP_GetScriptItems] 1,1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScriptItems]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetScriptItems]
END
GO

CREATE PROCEDURE [dbo].[SP_GetScriptItems]
        @ConfigurationID INT,
		@scriptId  INT
       
AS

BEGIN
                             select item.query('.') AS xmlItem
                             FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
                             CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') test(item)
                              WHERE ConfigurationID=@ConfigurationID 
                             and ISNULL(item.value('(./@id)[1]','varchar(max)'),'')=@scriptId
END
GO
