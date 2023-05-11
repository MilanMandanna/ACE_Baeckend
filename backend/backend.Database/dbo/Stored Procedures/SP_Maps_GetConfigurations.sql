SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/27/2022
-- Description:	Get Maps section details
-- Sample EXEC [dbo].[SP_Maps_GetConfigurations] 201, 'mapPackage'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Maps_GetConfigurations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Maps_GetConfigurations]
END
GO

CREATE PROCEDURE [dbo].[SP_Maps_GetConfigurations]
	@configurationId INT,
	@section NVARCHAR(250)
AS
BEGIN
	IF (@section = 'flyoveralerts')
	BEGIN
		SELECT 
        isnull(FlyOverAlert.value('(/flyover_alert/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(FlyOverAlert.value('(/flyover_alert/@alert_duration)[1]', 'INT'),'0') as AlertDuration, 
        isnull(FlyOverAlert.value('(/flyover_alert/@alert_sequential_delay)[1]', 'INT'),'0') as  AlertSequentialDelay,
        isnull(FlyOverAlert.value('(/flyover_alert/@lead_time)[1]', 'INT'),'') as ApproachAlertLeadTime
        FROM cust.tblFlyOverAlert 
        INNER JOIN cust.tblFlyOverAlertMap ON cust.tblFlyOverAlert.FlyOverAlertID = cust.tblFlyOverAlertMap.FlyOverAlertID 
        AND cust.tblFlyOverAlertMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'tabnavigation')
	BEGIN
        SELECT 
        isnull(WebMainItems.value('(/webmain/tab_nav/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(WebMainItems.value('(/webmain/tab_nav/@hover_color)[1]', 'varchar(max)'),'') as HoverColor, 
        isnull(WebMainItems.value('(/webmain/tab_nav/@next_hover_color)[1]', 'varchar(max)'),'') as NextHoverColor
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'extendedtabnavigation')
	BEGIN
        SELECT  
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/@timeout)[1]', 'FLOAT'),'0') as TimeOut, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@highlighted_color)[1]', 'varchar(max)'),'') as HighlitedColor, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@selected_color)[1]', 'varchar(max)'),'') as SelectedColor, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@future_color)[1]', 'varchar(max)'),'') as FutureColor
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'separators')
	BEGIN
        SELECT 
        isnull(Global.value('(/global/separators/@grouping)[1]', 'varchar(max)'),'') as Grouping, 
        isnull(Global.value('(/global/separators/@decimal)[1]', 'varchar(max)'),'') as Decimal
        FROM cust.tblGlobal 
        INNER JOIN cust.tblGlobalMap ON cust.tblGlobal.CustomID = cust.tblGlobalMap.CustomID 
        AND cust.tblGlobalMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'trackline')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/trackline/@color)[1]', 'varchar(max)'),'FF00FF00') as TrackLineColor,
        isnull(MapItems.value('(/maps/trackline/@width)[1]', 'FLOAT'),'0') as TrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline/@style)[1]', 'varchar(max)'),'eSolid') as TrackLineStyle,
        isnull(MapItems.value('(/maps/ftrackline/@color)[1]', 'varchar(max)'),'FF00FF00') as FutureTrackLineColor, 
        isnull(MapItems.value('(/maps/ftrackline/@width)[1]', 'FLOAT'),'0') as FutureTrackLineWidth, 
        isnull(MapItems.value('(/maps/ftrackline/@style)[1]', 'varchar(max)'),'eDashed')  as FutureTrackLineStyle
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = '3dtrackline')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/trackline3d/past/@color)[1]', 'varchar(max)'),'FF00FF00') as TrackLineColor,
        isnull(MapItems.value('(/maps/trackline3d/past/@scale)[1]', 'FLOAT'),'0.0') as TrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline3d/past/@style)[1]', 'varchar(max)'),'eSolid') as TrackLineStyle,
        isnull(MapItems.value('(/maps/trackline3d/future/@color)[1]', 'varchar(max)'),'FF00FF00') as FutureTrackLineColor, 
        isnull(MapItems.value('(/maps/trackline3d/future/@scale)[1]', 'FLOAT'),'0.0') as FutureTrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline3d/future/@style)[1]', 'varchar(max)'),'eDashed') as FutureTrackLineStyle
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'borders')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/borders/@enabled)[1]', 'varchar(max)'),'false') as IsEnabled, 
        isnull(MapItems.value('(/maps/borders/@hk)[1]', 'varchar(max)'),'false') as IsHongKongEnabled, 
        isnull(MapItems.value('(/maps/broadcast_borders/@enabled)[1]', 'varchar(max)'),'false') as IsBroadcastEnabled
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'worldguide')
	BEGIN
		SELECT 
        isnull(WebMainItems.value('(/webmain/world_guide/@active)[1]', 'varchar(max)'),'') as IsEnabled
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'help')
	BEGIN
		SELECT  
        isnull(WebMainItems.value('(/webmain/help_enabled)[1]', 'varchar(max)'),'') as IsEnabled
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId 
	END
	ELSE IF (@section = 'departure' OR @section = 'destination')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/dest_marker//@color)[1]', 'varchar(max)'),'') as DestinationMarkerColor, 
        isnull(MapItems.value('(/maps/depart_marker//@color)[1]', 'varchar(max)'),'') as DepartureMarkerColor 
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'mapPackage')
	BEGIN
		SELECT 
        ISNULL(MapItems.value('(/maps/map_package)[1]', 'varchar(max)'),'') as MapPackage 
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
END
GO
