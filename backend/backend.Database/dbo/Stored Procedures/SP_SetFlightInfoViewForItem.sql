
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date:  5/25/2022
-- Description:	this query will return the items based on configurationid and selected info
-- Sample: EXEC [dbo].[SP_SetFlightInfoViewForItem] 1,'Info Page 2_3D'
-- =============================================
IF OBJECT_ID('[dbo].[SP_SetFlightInfoViewForItem]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_SetFlightInfoViewForItem]
END
GO

CREATE PROCEDURE [dbo].[SP_SetFlightInfoViewForItem]
        @ConfigurationID INT,
		@selectedInfo NVARCHAR(300)
       
AS

BEGIN
                    SELECT ISNULL(Nodes.item.value('(./@infoitems)[1]','varchar(max)'),'') AS items
                    FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                    CROSS APPLY b.ScriptDefs.nodes('/script_defs/infopages/infopage') Nodes(item) 
					WHERE ConfigurationID  = @ConfigurationID AND UPPER(ISNULL(Nodes.item.value('(./@name)[1]','varchar(max)'),''))=@selectedInfo
   
END
GO

