
/****** Object:  StoredProcedure [dbo].[sp_mode_insertmode]    Script Date: 1/30/2022 9:23:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_insertmode] 1,'test',1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_insertmode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_insertmode]
END
GO

CREATE PROC [dbo].[sp_mode_insertmode]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT
AS 
BEGIN

DECLARE @strModeNode xml = '<mode_defs><mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode></mode_defs>'

						INSERT INTO cust.tblModeDefs(ModeDefs) VALUES(@strModeNode)
END
GO

