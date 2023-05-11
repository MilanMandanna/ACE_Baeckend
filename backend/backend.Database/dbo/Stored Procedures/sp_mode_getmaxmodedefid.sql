
/****** Object:  StoredProcedure [dbo].[sp_mode_getmaxmodedefid]    Script Date: 1/30/2022 9:17:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get max modedef id
-- Sample EXEC [dbo].[sp_mode_getmaxmodedefid] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmaxmodedefid]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmaxmodedefid]
END
GO

CREATE PROC [dbo].[sp_mode_getmaxmodedefid]
@configurationId INT
AS
BEGIN

SELECT
                        isnull(Max(Nodes.Mode.value('(./@id)', 'int')),'0')
                        FROM cust.tblModeDefs as Modes
                        CROSS APPLY Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                        INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                        AND cust.tblModeDefsMap.ConfigurationID = @configurationId

END
GO

