
/****** Object:  StoredProcedure [dbo].[sp_mode_removemode]    Script Date: 1/30/2022 9:24:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	remove node
-- Sample EXEC [dbo].[sp_mode_removemode] 1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_removemode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_removemode]
END
GO

CREATE PROC [dbo].[sp_mode_removemode]
@modeId INT,
@configurationId INT

AS
BEGIN
DECLARE @updateKey int,@ModeDefID INT
 SET @ModeDefID = (SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap  WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId  )    
	  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblModeDefs',@ModeDefID,@updateKey out
     
UPDATE cust.tblModeDefs 
                          SET ModeDefs.modify('delete /mode_defs/mode[@id = sql:variable("@modeId")]') 
                          WHERE cust.tblModeDefs.ModeDefID IN ( 
                          SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                          WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId AND ModeDefID = @updateKey)
END
GO


