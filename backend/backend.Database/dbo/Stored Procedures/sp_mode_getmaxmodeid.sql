
/****** Object:  StoredProcedure [dbo].[sp_mode_getmaxmodeid]    Script Date: 1/30/2022 9:18:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get max mode id
-- Sample EXEC [dbo].[sp_mode_getmaxmodeid]
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmaxmodeid]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmaxmodeid]
END
GO

CREATE PROC [dbo].[sp_mode_getmaxmodeid]
AS
BEGIN
SELECT MAX(cust.tblModeDefs.ModeDefID) FROM cust.tblModeDefs
END
GO

