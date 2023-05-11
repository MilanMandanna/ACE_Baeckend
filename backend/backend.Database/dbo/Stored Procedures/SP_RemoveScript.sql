
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	This sp will return name,id,scriptname and id based on configurationId
--Sample: EXEC [dbo].[SP_RemoveScript] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_RemoveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_RemoveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_RemoveScript]
        @configurationId INT
       
AS

BEGIN

       SELECT DISTINCT 
                ModesResult.ModeName as Name,
                ModesResult.ModeId as Id,
                ScriptIdLookup.ScriptName as ScriptName,
                ScriptIdLookup.ScriptId as ScriptId

                FROM

                (SELECT 
                isnull(Nodes.Mode.value('(./@name)[1]', 'varchar(max)'),'') as ModeName,
                isnull(Nodes.Mode.value('(./@id)[1]', 'varchar(max)'),'') as ModeId,
                isnull(Nodes.Mode.value('(./mode_item/@scriptidref)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblModeDefs as Modes
                cross apply Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID
                AND cust.tblModeDefsMap.ConfigurationID = @configurationId)

                as ModesResult

                LEFT OUTER JOIN(
                   SELECT
                isnull(Nodes.Script.value('(./@name)[1]', 'varchar(max)'),'') as ScriptName,
                isnull(Nodes.Script.value('(./@id)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblScriptDefs as Scripts
                cross apply Scripts.ScriptDefs.nodes('/script_defs/script') as Nodes(Script)
                INNER JOIN cust.tblScriptDefsMap ON cust.tblScriptDefsMap.ScriptDefID = Scripts.ScriptDefID
                AND cust.tblScriptDefsMap.ConfigurationID = @configurationId
                )

                as ScriptIdLookup ON ScriptIdLookup.ScriptId = ModesResult.ScriptId
END
GO

