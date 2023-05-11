
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Get the font based on configurationID
-- Sample: EXEC [cust].[SP_UpdateXML] 39 ,'webmain',''
-- =============================================
IF OBJECT_ID('[cust].[SP_UpdateXML]','P') IS NOT NULL

BEGIN
        DROP PROC [cust].[SP_UpdateXML]
END
GO

CREATE PROCEDURE [cust].[SP_UpdateXML]
	@configurationId INT,
    @section NVARCHAR(250),
    @xmlValue xml
AS
BEGIN
	DECLARE @updateKey INT

	IF (@section = 'flyoveralerts')
	BEGIN
		IF EXISTS (SELECT 1 FROM config_tblFlyOverAlert(@configurationId))
		BEGIN
			DECLARE @flyOverAlertID NVARCHAR(Max)
			SET @flyOverAlertID = (SELECT cust.tblFlyOverAlertMap.FlyOverAlertID FROM cust.tblFlyOverAlertMap WHERE cust.tblFlyOverAlertMap.ConfigurationID =  @configurationId)
			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblFlyOverAlert',@flyOverAlertID,@updateKey out
			UPDATE cust.tblFlyOverAlert
			SET FlyOverAlert = @xmlValue
			WHERE cust.tblFlyOverAlert.FlyOverAlertID IN (
						SELECT distinct cust.tblFlyOverAlertMap.FlyOverAlertID FROM cust.tblFlyOverAlertMap
						WHERE cust.tblFlyOverAlertMap.ConfigurationID = @configurationId AND cust.tblFlyOverAlertMap.FlyOverAlertID = @updateKey
						)
		END
		ELSE
		BEGIN
			INSERT INTO cust.tblFlyOverAlert (FlyOverAlert) VALUES(@xmlValue)
			SET @flyOverAlertID = (SELECT MAX(FlyOverAlertID) FROM cust.tblFlyOverAlert)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblFlyOverAlert', @flyOverAlertID 
		END
	END
    ELSE IF (@section = 'webmain')
	BEGIN
	    
		IF EXISTS (SELECT 1 FROM cust.config_tblWebmain(@configurationId))
		BEGIN
		     DECLARE @WebmainID NVARCHAR(Max)
		SET @WebmainID = (SELECT cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE cust.tblWebMainMap.ConfigurationID = @configurationId)
		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebMain',@WebmainID,@updateKey out
        UPDATE cust.tblWebMain
        SET WebMainItems = @xmlValue
        WHERE cust.tblWebMain.WebMainID IN (
	                SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap
	                WHERE cust.tblWebMainMap.ConfigurationID = @configurationId AND cust.tblWebMainMap.WebMainID = @updateKey
	                )
    END
	ELSE
		BEGIN
			INSERT INTO cust.tblWebMain (WebMainItems) VALUES(@xmlValue)
			SET @WebmainID= (SELECT MAX(WebMainID ) FROM cust.tblWebMain)
			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblWebMain',@WebmainID
		END
	END
    ELSE IF (@section = 'global')
	BEGIN
    
        UPDATE cust.tblGlobal
        SET cust.tblGlobal.Global = @xmlValue
        WHERE cust.tblGlobal.CustomID IN (
	                SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap
	                WHERE cust.tblGlobalMap.ConfigurationID = @configurationId AND cust.tblGlobalMap.CustomID = @updateKey
	                )
    END
    ELSE IF (@section = 'maps')
	BEGIN
		IF EXISTS (SELECT 1 FROM config_tblMaps(@configurationId))
		BEGIN
			DECLARE @MapID NVARCHAR(Max)
				 SET @MapID = (SELECT cust.tblMapsMap.MapID FROM cust.tblMapsMap WHERE cust.tblMapsMap.ConfigurationID =  @configurationId)
				EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMaps',@MapID,@updateKey out
			UPDATE cust.tblMaps
			SET MapItems = @xmlValue
			WHERE cust.tblMaps.MapID IN (
						SELECT distinct cust.tblMapsMap.MapID FROM cust.tblMapsMap
						WHERE cust.tblMapsMap.ConfigurationID = @configurationId AND MapID = @updateKey
						)
		END
		ELSE
		BEGIN
			INSERT INTO cust.tblMaps (MapItems) VALUES(@xmlValue)
			SET @mapID = (SELECT MAX(mapID) FROM cust.tblMaps)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblMaps', @mapID 

		END
    END
    ELSE IF(@section = 'layers')
    BEGIN
        UPDATE cust.tblMenu
        SET Layers = @xmlValue
        WHERE cust.tblMenu.MenuID IN (
	                SELECT distinct cust.tblMenuMap.MenuID FROM cust.tblMenuMap
	                WHERE cust.tblMenuMap.ConfigurationID = @configurationId
	                )
    END
END
