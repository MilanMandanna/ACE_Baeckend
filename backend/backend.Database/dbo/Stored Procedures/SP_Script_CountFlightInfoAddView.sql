
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	This query will return  the number of column name  from scriptdefs
-- Sample: EXEC [dbo].[SP_Script_CountFlightInfoAddView] 1,'Info Page 2_3D'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Script_CountFlightInfoAddView]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_Script_CountFlightInfoAddView]
END
GO

CREATE PROCEDURE [dbo].[SP_Script_CountFlightInfoAddView]
        @configurationId INT,
        @infoName  NVARCHAR(100)
AS

BEGIN
             
            SELECT COUNT(1) FROM cust.tblScriptDefs SD
           INNER JOIN cust.tblScriptDefsMap SDM ON SD.ScriptDefID = SDM.ScriptDefID
           CROSS APPLY SD.ScriptDefs.nodes('/script_defs/infopages/infopage') Nodes(item)
            where SDM.ConfigurationID = @configurationId and isnull(nodes.item.value('(./@name)[1]','nvarchar(max)'),'') = @infoName
END
GO
