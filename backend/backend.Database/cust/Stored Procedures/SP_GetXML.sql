SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 3/15/2022
-- Description:	Gets XML value from different custom tables
-- Sample EXEC [cust].[SP_GetXML] 18 , 'webmain'
-- =============================================

IF OBJECT_ID('[cust].[SP_GetXML]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_GetXML]
END
GO

CREATE PROCEDURE [cust].[SP_GetXML]
	@configurationId INT,
    @section NVARCHAR(250)
AS
BEGIN

	IF (@section = 'flyoveralerts')
	BEGIN
		SELECT FlyOverAlert as XMLValue
        FROM cust.tblFlyOverAlert
        INNER JOIN cust.tblFlyOverAlertMap ON cust.tblFlyOverAlertMap.FlyOverAlertID = cust.tblFlyOverAlert.FlyOverAlertID
        WHERE cust.tblFlyOverAlertMap.ConfigurationID = @configurationId
	END
    ELSE IF (@section = 'webmain')
	BEGIN
        SELECT WebMainItems as XMLValue
        FROM cust.tblWebMain
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
        WHERE cust.tblWebMainMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'global')
	BEGIN
        SELECT cust.tblGlobal.Global as XMLValue
        FROM cust.tblGlobal
        INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID
        WHERE cust.tblGlobalMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'maps')
	BEGIN
        SELECT MapItems as XMLValue
        FROM cust.tblMaps
        INNER JOIN cust.tblMapsMap ON cust.tblMapsMap.MapID = cust.tblMaps.MapID
        WHERE cust.tblMapsMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'layers')
	BEGIN
        SELECT Layers as XMLValue
        FROM cust.tblMenu as Menu 
        INNER JOIN cust.tblMenuMap ON cust.tblMenuMap.MenuID = Menu.MenuID 
        WHERE cust.tblMenuMap.ConfigurationID = @configurationId
    END
END
GO