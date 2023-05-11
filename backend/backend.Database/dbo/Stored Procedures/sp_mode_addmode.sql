
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_addmode] 1, 'test',1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_addmode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_addmode]
END
GO

CREATE PROC [dbo].[sp_mode_addmode]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT,
@configurationId INT

AS 
BEGIN

DECLARE @strModeNode xml = '<mode_defs><mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode></mode_defs>'

						UPDATE cust.tblModeDefs 
                        SET ModeDefs =  @strModeNode 
                         WHERE cust.tblModeDefs.ModeDefID IN ( 
                        SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                        WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId)
END
GO

