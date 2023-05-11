/****** Object:  StoredProcedure [dbo].[sp_mode_getmodeitemcount]    Script Date: 1/30/2022 9:21:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	getting mode count
-- Sample EXEC [dbo].[sp_mode_getmodeitemcount] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmodeitemcount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmodeitemcount]
END
GO

CREATE PROC [dbo].[sp_mode_getmodeitemcount]
@configurationId INT

AS
BEGIN

SELECT
                        Modes.ModeDefs.value('count(/mode_defs/mode)', 'int')
                        FROM cust.tblModeDefs as Modes
                        INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                        AND cust.tblModeDefsMap.ConfigurationID = @configurationId

END
GO

