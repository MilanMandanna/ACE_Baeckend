
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	 this SP returns name based on configurationid
-- Sample: EXEC [dbo].[SP_GetFlightInfoView] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFlightInfoView]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFlightInfoView]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFlightInfoView]
        @configurationId INT
       
AS

BEGIN

            SELECT ISNULL(Nodes.item.value('(./@name)[1]','varchar(max)'),'') AS name
             FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
              CROSS APPLY b.ScriptDefs.nodes('/script_defs/infopages/infopage') Nodes(item) 
            WHERE ConfigurationID  = @configurationId 
END
GO


