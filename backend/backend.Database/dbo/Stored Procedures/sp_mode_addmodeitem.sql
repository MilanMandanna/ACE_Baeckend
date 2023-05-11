

/****** Object:  StoredProcedure [dbo].[sp_mode_addmodeitem]    Script Date: 1/30/2022 9:14:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_addmodeitem] 1,'test',1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_addmodeitem]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_addmodeitem]
END
GO
CREATE PROC [dbo].[sp_mode_addmodeitem]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT,
@configurationId INT


AS 
BEGIN

DECLARE @strModeDef xml = '<mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode>'

	declare @modeNode xml = cast(@strModeDef as xml), @updateKey int,@ModeDefID INT
	SET @ModeDefID = (SELECT cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap WHERE cust.tblModeDefsmap.ConfigurationID = @configurationId)
	  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblModeDefs',@ModeDefID,@updateKey out
	
					    UPDATE cust.tblModeDefs 
                        SET ModeDefs.modify(' insert sql:variable("@modeNode") into /mode_defs[1]') 
                        WHERE cust.tblModeDefs.ModeDefID IN ( 
                        SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                        WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId AND ModeDefId = @updateKey)
						
						

END
GO

