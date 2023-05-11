--Update HD Briefings Config for Venue Hybrid configuration
IF EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 12)
BEGIN
	UPDATE tblPartNumber SET PartNumberCollectionID = 2 WHERE PartNumberID = 12
END
--Insert map Insets for Venue Hybrid configuration
--Need to confirm with Swops team on PartNumber
IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 32)
BEGIN
INSERT INTO tblPartNumber VALUES(32,2,'Insets (minsets)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-2559-%%%%%%_(VV)',32)
END
drop table if exists #TempTablesMissing;
SELECT SUBSTRING(name,1,len(name)-3) as name into #TempTablesMissing
FROM sys.objects
WHERE [type_desc] = 'USER_TABLE' and name like '%Map' and SUBSTRING(name,1,len(name)-3) not in (select tblName from tblConfigTables);

INSERT INTO tblConfigTables(tblName,IsUsedForMergeConfiguration) SELECT name,0 FROM #TempTablesMissing;
--Updating the tableFeatureSet Names



---- Create ConfigurationDefinition and FeatureSet mappings
BEGIN
		UPDATE tblConfigurationDefinitions
		 SET FeatureSetID = (
							CASE 
								WHEN ConfigurationDefinitionID = 1 THEN 1
								WHEN ConfigurationDefinitionID = 2 THEN 4
								WHEN ConfigurationDefinitionID = 3 THEN 5
								WHEN ConfigurationDefinitionID = 4 THEN 3
								WHEN ConfigurationDefinitionID = 5 THEN 6
							END
						);
						
END

---**** Region Feature set table script ****---

-- Truncate featureset table --
TRUNCATE TABLE tblFeatureSet
-- end --

-- Insert fresh data --


INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'Collins-Admin-ItemsList', 'Populations,Placenames,Airports,World-Guide-Cities,Insets')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (2, 'Collins-Admin-ItemsList', 'Flight data, System Config,Briefings,Timezone Database,Download test configuration,Sizes configurations,Mobile Configuration Platform,Content 3D Aircraft Models, Ticker Ads configuration,mmobilecc configuration,Discrete inputs,Briefings (non hd),Map package blue marble,Map package borderless blue marble,Content htse 1280x720,Content asxi3 standard 3d,Content asxi3 aircraft models,Content asx4/5 aircraft models,installation scripts venue hybrid,FDC Map Menu list,Site Identification configuration,System Configuraiton,Flight Data configuration,Timezone Database configuration,Flight Phase configuration,ACARS Data configuration,Content 3D configuration,Content Mobile configuration,Venue Next scripts,CES scripts,Resolution Map configuration,Briefings configuration,Flight Deck configuration')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (7, 'Collins-Admin-ItemsList', 'Populations,Placenames,Airports,World-Guide-Cities,Insets')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (3, 'Collins-Admin-ItemsList', 'Populations,Placenames,Airports,World-Guide-Cities,ACARS Data configuration,Insets')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Global-Fonts', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Global-Language', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Global-Time', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Global-Units', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-3DTracklineEditor', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-Departure-Destination', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-ExtendedTabNavigation', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-FlyoverAlerts', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-HelpOption', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-LayersDisplayList', 'Distance To Poi,Trackline,Compass,HUD,Night,Borders,North Indicator,Fodors,Cities,Capitals,Land Features,Water Features,Airports,Terrain,Airports')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-LayersList', 'distance to poi,trackline,compass,hud,night,borders,north indicator,fodors,pn cities,pn capitals,pn land features,pn water features,pn_airports,terrain,pn airports')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-MapBorders', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-MapBorders-Broadcast', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-MapBorders-Html', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-TabNavigation', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-TerminalMaps', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-TracklineEditor', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Maps-WorldGuides', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-OverheadAutoplay-Modes', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-OverheadAutoplay-Personalities', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-OverheadAutoplay-Profiles', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-OverheadAutoplay-Routes', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-OverheadAutoplay-ScriptDisplayList', 'Flight Preview,Midflight,Global Zoom,Compass,Window Seat,Image,Overhead,Video,Flight Info,Points of Interest,Total Route,Timezone Globe,World Clocks,Makkah Compass,High Resolution,Makkah,Miqat,Ticker Image,Ticker Info')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-OverheadAutoplay-ScriptList', 'e3DPreFlight,e3DMidFlight,e3DZspace,e3DRli,e3DPanorama,e3DImage,e3DOverhead,e3DVideo,e3DFlightData,e3DRotatingPOI,e3DTotalRoute,e3DTimezone,e3DWorldClocks,e3DRliMecca,e3DHighestRes,e3DMakkah,e3DMiqat,eTickerImage,eTickerFd')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-OverheadAutoplay-Scripts', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-OverheadAutoplay-Triggers', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Ticker-MaxSpeed', '7')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Ticker-MinSpeed', '1')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Ticker-ParametersDisplayList', 'Local Time At Destination,Local Time At Departure,Local Time At Departure ,Local Time At Destination,Estimated Time Of Arrival,Time To Destination,Time To Destination,Time Since Departure,Distance To Destination,Distance To Destination,Latitude,Longitude,Heading,Headwind Tailwind,Wind Direction,Wind Speed,Altitude,GroundSpeed,Outside Air Temperature,TrueAirspeed,Mach,DistancTraveled')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-Ticker-ParametersList', 'eLocalTimeAtDestination,eLocalTimeAtDeparture,eLocalTimeAtPresentPosition,eLocalTimeAtDestCityName,eEstimatedTimeOfArrival,eTimeToDestination,eTimeToDestCityName,eTimeSinceDeparture,eDistanceToDestination,eDistanceToDestCityName,eLatitude,eLongitude,eHeading,eHeadwindTailwind,eWindDirection,eWindSpeed,eAltitude,eGroundSpeed,eOutsideAirTemperature,eTrueAirspeed,eMach,eDistanceTraveled')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-ViewsDisplayList', 'Autoplay,Flight Preview,Total Route,Mid Flight,Overhead, Compass,World Clocks,Timezone Globe,Window Seat,Flight Information, Command Center,Makkah,Points of Interest')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-ViewsList', 'autoplay,flight preview,total route,landscape,overhead,compass,world clocks,time zone, panorama,flight info,command center,makkah,rotating poi')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomConfig-ViewsMaxPresets', '3')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomContent', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomContent-Airports', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomContent-Country', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomContent-Logos', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomContent-MapPackage', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomContent-Placenames', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomContent-Regions', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'CustomContent-SplashScreen', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'FlightInfo-MaxNumOfParameters', '15')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'FlightInfo-ParametersDisplayList', 'Local Time At Present Position,Local Time At Dest City Name,Estimated Time Of Arrival, Time To Dest City Name,Time Since Departure, Distance To Dest City Name,Latitude,Longitude,Heading, Head wind Tail wind,Wind Direction,Wind Speed,Altitude,Ground Speed,Outside Air Temperature,True Airspeed,Mach,Distance Traveled,Distance To Destination,Time to Destination')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'FlightInfo-ParametersList', 'eLocalTimeAtPresentPosition,eLocalTimeAtDestCityName,eEstimatedTimeOfArrival,eTimeToDestCityName,eTimeSinceDeparture,eDistanceToDestCityName,eLatitude,eLongitude,eHeading,eHeadwindTailwind,eWindDirection,eWindSpeed,eAltitude,eGroundSpeed,eOutsideAirTemperature,eTrueAirspeed,eMach,eDistanceTraveled,eDistanceToDestination,eTimeToDestination')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (2, 'IsEditable', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (7, 'IsEditable', 'TRUE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (6, 'IsEditable', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (3, 'IsEditable', 'FALSE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (5, 'IsEditable', 'TRUE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'IsEditable', 'TRUE')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'MakkahCalculation-TypesDisplayList', 'MWL (Muslim World League);Jafari (Shia Ithana Ashari, Leva Research Institute);Karachi (University of Islamic Science);ISNA (Islamic Society of North America);Makkah (Umm Al-Quara University); Egypt (Egyptian General Authority of Survey);Tehran (Institute of Geophysics, University of Tehran)')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'MakkahCalculation-TypesList', 'mwl,jafari,karachi,isna,makkah,egypt,tehran')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'Modlist-Resolutions', '15360, 7680, 3840, 1920, 960, 480, 240, 120, 60, 30')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'ViewsMenu', 'Auto Play, Flight Preview, Total Route, Landscape, Overhead, Compass, World Clocks, Time Zone, Global Zoom, Diagnostics, Flight Data, Panorama, Command Center, Makkah, Flight Info, Rotating POI')
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'WorldClocks-MaxNumOfCities', '12')

-- end data --
---**** Region Feature set table script ****---

INSERT INTO tblUserMenus(MenuName,Description,MenuClass,MinimizedMenuClass,RouteURL) VALUES
('Home','Home Menu','sideMenuBaseSettings sideMenuhome','minimizedSideMenuBaseSettings sideMenuhome','/dashboard'),
('Airshow Manager','Airshow Manager','sideMenuBaseSettings sidemenuAirshowManager_Icon','minimizedSideMenuBaseSettings sidemenuAirshowManager_Icon','/airshow'),
('Settings','Settings','sideMenuBaseSettings sideMenusettings','minimizedSideMenuBaseSettings sideMenusettings','/settings'),
('User Profile','User Profile','sideMenuBaseSettings sideMenuUserProfile_Icon',NULL,'/settings/userprofile'),
('User Administration','User Administration','sideMenuBaseSettings sideMenuUserAdministration_Icon',NULL,'/settings/useradministration'),
('Aircraft','Aircraft','sideMenuBaseSettings sideMenuAircraft_Icon',NULL,'/settings/aircraft'),
('Administration','Administration','sideMenuBaseSettings sideMenuAdministration_Icon',NULL,'/settings/administration'),
('Build','Build','sideMenuBaseSettings sideMenubuild_icon','minimizedSideMenuBaseSettings sideMenubuild_icon','/builds'),
('Customize Airshow','Customize Airshow','sideMenuBaseSettings sideMenuCustomizeAirshow_Icon','minimizedSideMenuBaseSettings sideMenuCustomizeAirshow_Icon','/airshow/customize'),
('Custom Configuration','Custom Configuration','sideMenuBaseSettings',NULL,'/airshow/customconfigdetail'),
('Global','Global','sideMenuBaseSettings',NULL,'/airshow/globalconfiglist'),
('Maps','Maps','sideMenuBaseSettings',NULL,'/airshow/mapsconfiglist'),
('Overhead/Autoplay','Overhead/Autoplay','sideMenuBaseSettings',NULL,'/airshow/autoplay'),
('Ticker','Ticker','sideMenuBaseSettings',NULL,'/airshow/ticker'),
('Views','Views','sideMenuBaseSettings',NULL,'/airshow/views'),
('Custom Content','Custom Content','sideMenuBaseSettings',NULL,'/airshow/customcontent'),
('Map Package','Map Package','sideMenuBaseSettings',NULL,'/airshow/customcontent/mappackage'),
('Logos/Ads','Logos/Ads','sideMenuBaseSettings',NULL,'/airshow/customcontent/logo'),
('Splash Screen','Home Menu','sideMenuBaseSettings',NULL,'/airshow/customcontent/spalshscreen'),
('Placenames','Placenames','sideMenuBaseSettings',NULL,'/airshow/customcontent/placenames'),
('Airports','Airports','sideMenuBaseSettings',NULL,'/airshow/customcontent/airport'),
('Country','Country','sideMenuBaseSettings',NULL,'/airshow/customcontent/country'),
('Regions','Regions','sideMenuBaseSettings',NULL,'/airshow/customcontent/region'),
('Collins Administrator - Only','Collins Administrator - Only','sideMenuBaseSettings',NULL,'/airshow/customize/collinsadmin'),
('Logout','Logout','sideMenuBaseSettings','minimizedSideMenuBaseSettings','/login');


-- Parent Menu Update
DECLARE @settingsMenuId INT
SELECT @settingsMenuId=MenuId FROM tblUserMenus WHERE MenuName='Settings'
UPDATE tblUserMenus SET ParentMenuId=@settingsMenuId WHERE MenuName in('User Profile','User Administration','Aircraft','Administration');


DECLARE @customizeAirshowMenuId INT
SELECT @customizeAirshowMenuId=MenuId FROM tblUserMenus WHERE MenuName='Customize Airshow'
UPDATE tblUserMenus SET ParentMenuId=@customizeAirshowMenuId WHERE MenuName in('Custom Configuration','Custom Content','Collins Administrator - Only');

DECLARE @customConfigurationMenuId INT
SELECT @customConfigurationMenuId=MenuId FROM tblUserMenus WHERE MenuName='Custom Configuration'
UPDATE tblUserMenus SET ParentMenuId=@customConfigurationMenuId WHERE MenuName in('Global','Maps','Overhead/Autoplay','Ticker','Views');


DECLARE @customContentMenuId INT
SELECT @customContentMenuId=MenuId FROM tblUserMenus WHERE MenuName='Custom Content'
UPDATE tblUserMenus SET ParentMenuId=@customContentMenuId WHERE MenuName in('Map Package','Logos/Ads','Splash Screen','Placenames','Airports','Country','Regions');



UPDATE tblUserMenus SET IsConfigIdRequired=1 WHERE MenuName in('Customize Airshow','Custom Configuration','Global','Maps','Overhead/Autoplay',
'Ticker','Views','Custom Content','Map Package','Logos/Ads','Splash Screen','Placenames','Airports','Country','Regions','Collins Administrator - Only');

UPDATE tblUserMenus SET isEnabled=1;


--Manage Accounts
DECLARE @mngAccntClaimId UNIQUEIDENTIFIER
SELECT @mngAccntClaimId=ID from UserClaims WHERE Name='Manage Accounts';
INSERT INTO tblMenuClaims
SELECT MenuId,@mngAccntClaimId,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Aircraft','User Administration', 'Collins Administrator - Only');

--Manage Role Assignment
DECLARE @mngRoleClaimId UNIQUEIDENTIFIER
SELECT @mngRoleClaimId=ID from UserClaims WHERE Name='Manage Role Assignment';
INSERT INTO tblMenuClaims
SELECT MenuId,@mngRoleClaimId,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','User Administration');

--Manage Operator
DECLARE @mngOperatorClaimId UNIQUEIDENTIFIER
SELECT @mngOperatorClaimId=ID from UserClaims WHERE Name='Manage Operator';
INSERT INTO tblMenuClaims
SELECT MenuId,@mngOperatorClaimId,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Aircraft','User Administration','Build','Customize Airshow',
'Custom Configuration','Global','Maps','Overhead/Autoplay','Ticker','Views','Custom Content'
,'Map Package'
,'Logos/Ads'
,'Splash Screen'
,'Placenames'
,'Airports'
,'Country'
,'Regions','Airshow Manager');

--View Operator
DECLARE @viewOperatorClaimId UNIQUEIDENTIFIER
SELECT @viewOperatorClaimId=ID from UserClaims WHERE Name='View Operator';
INSERT INTO tblMenuClaims
SELECT MenuId,@viewOperatorClaimId,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Aircraft','User Administration','Build','Customize Airshow',
'Custom Configuration','Global','Maps','Overhead/Autoplay','Ticker','Views','Custom Content'
,'Map Package'
,'Logos/Ads'
,'Splash Screen'
,'Placenames'
,'Airports'
,'Country'
,'Regions','Airshow Manager');


--Manage Aircraft
DECLARE @manageAircraftClaimId UNIQUEIDENTIFIER
SELECT @manageAircraftClaimId=ID from UserClaims WHERE Name='Manage Aircraft';
INSERT INTO tblMenuClaims
SELECT MenuId,@manageAircraftClaimId,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Aircraft','Build','Customize Airshow',
'Custom Configuration','Global','Maps','Overhead/Autoplay','Ticker','Views','Custom Content'
,'Map Package'
,'Logos/Ads'
,'Splash Screen'
,'Placenames'
,'Airports'
,'Country'
,'Regions','Airshow Manager');


--Administer Operator
DECLARE @administerOperatorClaimId UNIQUEIDENTIFIER
SELECT @administerOperatorClaimId=ID from UserClaims WHERE Name='Administer Operator';
INSERT INTO tblMenuClaims
SELECT MenuId,@administerOperatorClaimId,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Aircraft','User Administration','Build','Customize Airshow',
'Custom Configuration','Global','Maps','Overhead/Autoplay','Ticker','Views','Custom Content'
,'Map Package'
,'Logos/Ads'
,'Splash Screen'
,'Placenames'
,'Airports'
,'Country'
,'Regions','Airshow Manager');

--Administer Aircraft
DECLARE @administerAircraftClaimId UNIQUEIDENTIFIER
SELECT @administerAircraftClaimId=ID from UserClaims WHERE Name='Administer Aircraft';
INSERT INTO tblMenuClaims
SELECT MenuId,@administerAircraftClaimId,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Aircraft','Build','Customize Airshow',
'Custom Configuration','Global','Maps','Overhead/Autoplay','Ticker','Views','Custom Content'
,'Map Package'
,'Logos/Ads'
,'Splash Screen'
,'Placenames'
,'Airports'
,'Country'
,'Regions','Airshow Manager');


--Manage Global Configuration
DECLARE @manageGlobalConfiguration UNIQUEIDENTIFIER
SELECT @manageGlobalConfiguration=ID from UserClaims WHERE Name='Manage Global Configuration';
INSERT INTO tblMenuClaims
SELECT MenuId,@manageGlobalConfiguration,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Build','Customize Airshow',
'Custom Configuration','Global','Maps','Overhead/Autoplay','Ticker','Views','Custom Content'
,'Map Package'
,'Logos/Ads'
,'Splash Screen'
,'Placenames'
,'Airports'
,'Country'
,'Regions','Airshow Manager');

--ManageProductConfiguration
DECLARE @manageProductConfiguration UNIQUEIDENTIFIER
SELECT @manageProductConfiguration=ID from UserClaims WHERE Name='ManageProductConfiguration';
INSERT INTO tblMenuClaims
SELECT MenuId,@manageProductConfiguration,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Build','Customize Airshow',
'Custom Configuration','Global','Maps','Overhead/Autoplay','Ticker','Views','Custom Content'
,'Map Package'
,'Logos/Ads'
,'Splash Screen'
,'Placenames'
,'Airports'
,'Country'
,'Regions','Airshow Manager');

--ManagePlatformConfiguration
DECLARE @managePlatformConfiguration UNIQUEIDENTIFIER
SELECT @managePlatformConfiguration=ID from UserClaims WHERE Name='ManagePlatformConfiguration';
INSERT INTO tblMenuClaims
SELECT MenuId,@managePlatformConfiguration,0 FROM tblUserMenus WHERE MenuName 
IN('Home','Settings','User Profile','Logout','Build','Customize Airshow',
'Custom Configuration','Global','Maps','Overhead/Autoplay','Ticker','Views','Custom Content'
,'Map Package'
,'Logos/Ads'
,'Splash Screen'
,'Placenames'
,'Airports'
,'Country'
,'Regions','Airshow Manager');

DECLARE @siteAdminClaimId UNIQUEIDENTIFIERSELECT @siteAdminClaimId=ID from UserClaims WHERE Name='Manage Site Settings';INSERT INTO tblMenuClaimsSELECT MenuId,@siteAdminClaimId,0 FROM tblUserMenus WHERE MenuName IN('Administration');


IF NOT EXISTS (SELECT OutputTypeID FROM [dbo].[tblOutputTypes] WHERE OutputTypeName = 'AS4XXX')
BEGIN
INSERT INTO [dbo].[tblOutputTypes] SELECT 1, 'AS4XXX',NULL
END
IF NOT EXISTS (SELECT OutputTypeID FROM [dbo].[tblOutputTypes] WHERE OutputTypeName = 'AS500')
BEGIN
INSERT INTO [dbo].[tblOutputTypes] SELECT 2,'AS500',NULL
END
IF NOT EXISTS (SELECT OutputTypeID FROM [dbo].[tblOutputTypes] WHERE OutputTypeName = 'CES')
BEGIN
INSERT INTO [dbo].[tblOutputTypes] SELECT 3,'CES',NULL
END
IF NOT EXISTS (SELECT OutputTypeID FROM [dbo].[tblOutputTypes] WHERE OutputTypeName = 'Thales2D')
BEGIN
INSERT INTO [dbo].[tblOutputTypes] SELECT 4,'Thales2D',NULL
END
IF NOT EXISTS (SELECT OutputTypeID FROM [dbo].[tblOutputTypes] WHERE OutputTypeName = 'PAC3D')
BEGIN
INSERT INTO [dbo].[tblOutputTypes] SELECT 5,'PAC3D',NULL
END
IF NOT EXISTS (SELECT OutputTypeID FROM [dbo].[tblOutputTypes] WHERE OutputTypeName = 'VenueNext')
BEGIN
INSERT INTO [dbo].[tblOutputTypes] SELECT 6,'VenueNext',1
END
IF NOT EXISTS (SELECT OutputTypeID FROM [dbo].[tblOutputTypes] WHERE OutputTypeName = 'VenueHybrid')
BEGIN
INSERT INTO [dbo].[tblOutputTypes] SELECT 7,'VenueHybrid',2
END

IF EXISTS (SELECT 1 FROM tblConfigurationComponentType WHERE NAME = 'Sizes configuration')
BEGIN
	UPDATE tblConfigurationComponentType SET NAME = 'Sizes configurations', Description = 'Sizes configurations' WHERE Name = 'Sizes configuration'
END

--Update IsConfigurable flag to hide the FeatureSet tags from UI
UPDATE tblFeatureSet SET IsConfigurable = 0 WHERE Name IN 
('CustomConfig-Maps-LayersList'
, 'CustomConfig-OverheadAutoplay-ScriptList'
, 'CustomConfig-Ticker-ParametersList'
, 'CustomConfig-ViewsList'
, 'FlightInfo-ParametersList'
, 'MakkahCalculation-TypesList')

--Update appropriate values in FeatureSet->Input Type field

UPDATE tblFeatureSet SET InputTypeID = 3 WHERE Name IN ('Collins-Admin-ItemsList','CustomConfig-Maps-LayersDisplayList','CustomConfig-Maps-LayersList','CustomConfig-OverheadAutoplay-ScriptDisplayList','CustomConfig-Ticker-ParametersDisplayList','CustomConfig-Ticker-ParametersList','CustomConfig-ViewsDisplayList','CustomConfig-ViewsList','FlightInfo-ParametersDisplayList','FlightInfo-ParametersList','MakkahCalculation-TypesDisplayList','MakkahCalculation-TypesList','ViewsMenu','Modlist-Resolutions','CustomConfig-OverheadAutoplay-ScriptList')

UPDATE tblFeatureSet SET InputTypeID = 2 WHERE Name IN ('CustomConfig','CustomConfig-Global-Fonts','CustomConfig-Global-Language','CustomConfig-Global-Time','CustomConfig-Global-Units','CustomConfig-Maps-3DTracklineEditor','CustomConfig-Maps-Departure-Destination','CustomConfig-Maps-ExtendedTabNavigation','CustomConfig-Maps-FlyoverAlerts','CustomConfig-Maps-HelpOption','CustomConfig-Maps-MapBorders','CustomConfig-Maps-MapBorders-Broadcast','CustomConfig-Maps-MapBorders-Html','CustomConfig-Maps-TabNavigation','CustomConfig-Maps-TerminalMaps','CustomConfig-Maps-TracklineEditor','CustomConfig-Maps-WorldGuides','CustomConfig-OverheadAutoplay-Modes','CustomConfig-OverheadAutoplay-Personalities','CustomConfig-OverheadAutoplay-Profiles','CustomConfig-OverheadAutoplay-Routes','CustomConfig-OverheadAutoplay-Scripts','CustomConfig-OverheadAutoplay-Triggers','CustomContent','CustomContent-Airports','CustomContent-Country','CustomContent-Logos','CustomContent-MapPackage','CustomContent-Placenames','CustomContent-Regions','CustomContent-SplashScreen','IsEditable')

UPDATE tblFeatureSet SET InputTypeID = 1 WHERE Name IN ('CustomConfig-Ticker-MaxSpeed','CustomConfig-Ticker-MinSpeed','CustomConfig-ViewsMaxPresets','FlightInfo-MaxNumOfParameters','WorldClocks-MaxNumOfCities')

--Update KeyFeatureSetID for dropdown Input Type which has key value pair (eg: Info parametrs list contains both xml names and display names)
DECLARE @tempFeatureSet TABLE(Id INT IDENTITY(1,1), FeatureSetId INT)
DECLARE @id INT, @featureSetID INT
INSERT INTO @tempFeatureSet (FeatureSetId ) SELECT DISTINCT FeatureSetID FROM tblFeatureSet 
WHILE (SELECT COUNT(*) FROM @tempFeatureSet) > 0  
BEGIN
	SET @id = (SELECT TOP 1 Id FROM @tempFeatureSet)
	SET @featureSetID = (SELECT FeatureSetId FROM @tempFeatureSet WHERE Id = @id)
	IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE (Name = 'CustomConfig-Maps-LayersDisplayList') AND FeatureSetID = @featureSetID)
	BEGIN
		UPDATE tblFeatureSet SET KeyFeatureSetID = (SELECT ID FROM tblFeatureSet WHERE Name = 'CustomConfig-Maps-LayersList' AND FeatureSetID = @featureSetID) 
			WHERE Name = 'CustomConfig-Maps-LayersDisplayList' AND FeatureSetID = @featureSetID
	END
	IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE (Name = 'CustomConfig-OverheadAutoplay-ScriptDisplayList') AND FeatureSetID = @featureSetID)
	BEGIN
		UPDATE tblFeatureSet SET KeyFeatureSetID = (SELECT ID FROM tblFeatureSet WHERE Name = 'CustomConfig-OverheadAutoplay-ScriptList' AND FeatureSetID = @featureSetID) 
			WHERE Name = 'CustomConfig-OverheadAutoplay-ScriptDisplayList' AND FeatureSetID = @featureSetID
	END
	IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE (Name = 'CustomConfig-Ticker-ParametersDisplayList') AND FeatureSetID = @featureSetID)
	BEGIN
		UPDATE tblFeatureSet SET KeyFeatureSetID = (SELECT ID FROM tblFeatureSet WHERE Name = 'CustomConfig-Ticker-ParametersList' AND FeatureSetID = @featureSetID) 
			WHERE Name = 'CustomConfig-Ticker-ParametersDisplayList' AND FeatureSetID = @featureSetID
	END
	IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE (Name = 'CustomConfig-ViewsDisplayList') AND FeatureSetID = @featureSetID)
	BEGIN
		UPDATE tblFeatureSet SET KeyFeatureSetID = (SELECT ID FROM tblFeatureSet WHERE Name = 'CustomConfig-ViewsList' AND FeatureSetID = @featureSetID) 
			WHERE Name = 'CustomConfig-ViewsDisplayList' AND FeatureSetID = @featureSetID
	END
	IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE (Name = 'FlightInfo-ParametersDisplayList') AND FeatureSetID = @featureSetID)
	BEGIN
		UPDATE tblFeatureSet SET KeyFeatureSetID = (SELECT ID FROM tblFeatureSet WHERE Name = 'FlightInfo-ParametersList' AND FeatureSetID = @featureSetID) 
			WHERE Name = 'FlightInfo-ParametersDisplayList' AND FeatureSetID = @featureSetID
	END
	IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE (Name = 'MakkahCalculation-TypesDisplayList') AND FeatureSetID = @featureSetID)
	BEGIN
		UPDATE tblFeatureSet SET KeyFeatureSetID = (SELECT ID FROM tblFeatureSet WHERE Name = 'MakkahCalculation-TypesList' AND FeatureSetID = @featureSetID) 
			WHERE Name = 'MakkahCalculation-TypesDisplayList' AND FeatureSetID = @featureSetID
	END
	DELETE FROM @tempFeatureSet WHERE Id = @id
END


IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE NAME = 'Save Product Configuration' AND ID = 'F7DED0F2-CE81-48FF-A8A8-3F86B0431842')
BEGIN
	INSERT INTO tblTaskType (ID, Name, Description, AzureDefinitionID, ShouldShowInBuildDashboard)
	VALUES ('F7DED0F2-CE81-48FF-A8A8-3F86B0431842', 'Save Product Configuration', 'Create branch for platforms', NULL, 0)
END

IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE NAME = 'Save Products' AND ID = '1F544915-D100-4F64-9D95-BDDC25064B5A')
BEGIN
	INSERT INTO tblTaskType (ID, Name, Description, AzureDefinitionID, ShouldShowInBuildDashboard)
	VALUES ('1F544915-D100-4F64-9D95-BDDC25064B5A', 'Save Products', 'Create branch for products', NULL, 0)
END

IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE NAME = 'Save Aircraft Configuration' AND ID = '78AAE932-A344-4E06-B951-925DCD9FD881')
BEGIN
	INSERT INTO tblTaskType (ID, Name, Description, AzureDefinitionID, ShouldShowInBuildDashboard)
	VALUES ('78AAE932-A344-4E06-B951-925DCD9FD881', 'Save Aircraft Configuration', 'Create branch for aircrafts', NULL, 0)
END
IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE Name='Venue Hybrid'AND ID = 'f490b3b4-4804-4d4a-ba26-7165cb2cbfda') 
BEGIN 
	INSERT INTO tblTaskType(ID,Name,Description,ShouldShowInBuildDashboard) 
	VALUES('f490b3b4-4804-4d4a-ba26-7165cb2cbfda','Venue Hybrid','Venue Hybrid',1); 
END

UPDATE [dbo].[tblLanguages] SET ISLatinScript=0 where ID=-1

Update tblFeatureSet SET Value = 'Local Time At Destination,Local Time At Departure,Local Time At Present Postition ,Local Time At Dest city Name,Estimated Time Of Arrival,Time To Destination,Time To Dest City Name,Time Since Departure,Distance To Destination,Distance To DestCity Name,Latitude,Longitude,Heading,Headwind Tailwind,Wind Direction,Wind Speed,Altitude,GroundSpeed,Outside Air Temperature,TrueAirspeed,Mach,DistancTraveled,Local Time At Departure City Name' where name='CustomConfig-Ticker-ParametersDisplayList'
Update tblFeatureSet SET Value =  'eLocalTimeAtDestination,eLocalTimeAtDeparture,eLocalTimeAtPresentPosition,eLocalTimeAtDestCityName,eEstimatedTimeOfArrival,eTimeToDestination,eTimeToDestCityName,eTimeSinceDeparture,eDistanceToDestination,eDistanceToDestCityName,eLatitude,eLongitude,eHeading,eHeadwindTailwind,eWindDirection,eWindSpeed,eAltitude,eGroundSpeed,eOutsideAirTemperature,eTrueAirspeed,eMach,eDistanceTraveled,eLocalTimeAtDepartureCityName' where name ='CustomConfig-Ticker-ParametersList'

DECLARE @siteAdminClaimsId UNIQUEIDENTIFIER
SELECT @siteAdminClaimsId=ID from UserClaims WHERE Name='Manage Site Settings';

UPDATE tblMenuClaims SET ClaimID=@siteAdminClaimsId WHERE MenuID in(SELECT MenuId FROM tblUserMenus WHERE MenuName 
IN('Administration'))


Update tblFeatureSet SET Value =  'Flight Preview,Midflight,Global Zoom,Compass,Window Seat,Image,Overhead,Video,Flight Info,Points of Interest,Total Route,Timezone Globe,World Clocks,Makkah Compass,High Resolution,Makkah,Miqat,Ticker Image,Ticker Info,Welcome Logo' where name ='CustomConfig-OverheadAutoplay-ScriptDisplayList'

Update tblFeatureSet SET Value = 'e3DPreFlight,e3DMidFlight,e3DZspace,e3DRli,e3DPanorama,e3DImage,e3DOverhead,e3DVideo,e3DFlightData,e3DRotatingPOI,e3DTotalRoute,e3DTimezone,e3DWorldClocks,e3DRliMecca,e3DHighestRes,e3DMakkah,e3DMiqat,eTickerImage,eTickerFd,e3DWelcomeLogo' where name ='CustomConfig-OverheadAutoplay-ScriptList'

IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE Name='Import Infospelling'AND ID = 'BB493CF6-2F9E-4305-B4A1-CFA9A9994721') 
BEGIN 
Insert into tbltasktype (ID,Name,Description,AzureDefinitionID,ShouldShowInBuildDashboard) 
Values('BB493CF6-2F9E-4305-B4A1-CFA9A9994721','Import Infospelling','Importing ifo spelling',NULL,0)
END

Update tblFeatureSet SET Value = 'e3DPreFlight,e3DMidFlight,e3DZspace,e3DRli,e3DPanorama,e3DImage,e3DOverhead,e3DVideo,e3DFlightData,e3DRotatingPOI,e3DTotalRoute,e3DTimezone,e3DWorldClocks,e3DRliMecca,e3DHighestRes,e3DMakkah,e3DMiqat,eTickerImage,eTickerFd,e3DWelcomeLogo' where name ='CustomConfig-OverheadAutoplay-ScriptList'



IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE NAME = 'Import Fonts' AND ID = 'EC9D8357-56F9-49DD-BA88-C04A531FB708')
BEGIN
    INSERT INTO tblTaskType (ID, Name, Description, AzureDefinitionID, ShouldShowInBuildDashboard)
    VALUES ('EC9D8357-56F9-49DD-BA88-C04A531FB708', 'Import Fonts', 'Importing Fonts', NULL, 0)
END


IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='font data')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'font data','font data' FROM tblConfigurationComponentType 
END

UPDATE tblpartnumber SET DefaultPartNumber = '072-4599-%%%%%%' WHERE Name = 'HD Briefings Config (hdbrfcfg)' AND PartNumberID = '1'
UPDATE tblpartnumber SET DefaultPartNumber = '072-4601-%%%%%%' WHERE Name = 'HD Briefings Config CII' AND PartNumberID = '2'
UPDATE tblpartnumber SET DefaultPartNumber = '072-4603-%%%%%%' WHERE Name = 'HD Briefings Content (hdbrfcnt)' AND PartNumberID = '3'
UPDATE tblpartnumber SET DefaultPartNumber = '072-4605-%%%%%%' WHERE Name = 'HD Briefings Content CII' AND PartNumberID = '4'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2559-%%%%%%' WHERE Name = 'Customer Content (mcc)' AND PartNumberID = '5'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2559-%%%%%%' WHERE Name = 'Configuration (mcfg)' AND PartNumberID = '6'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2559-%%%%%%' WHERE Name = 'Content (mcnt)' AND PartNumberID = '7'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2559-%%%%%%' WHERE Name = 'Data (mdata)' AND PartNumberID = '8'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2559-%%%%%%' WHERE Name = 'Insets (minsets)' AND PartNumberID = '9'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2559-%%%%%%' WHERE Name = 'Mobile Configuration (mmobilecc)' AND PartNumberID = '10'
UPDATE tblpartnumber SET DefaultPartNumber = '072-3222-%%%%%%' WHERE Name = 'Timezone Database (mtz)' AND PartNumberID = '11'
UPDATE tblpartnumber SET DefaultPartNumber = '072-4600-%%%%%%' WHERE Name = 'HD Briefings Config (hdbrfcfg)' AND PartNumberID = '12'
UPDATE tblpartnumber SET DefaultPartNumber = '072-4602-%%%%%%' WHERE Name = 'HD Briefings Config CII' AND PartNumberID = '13'
UPDATE tblpartnumber SET DefaultPartNumber = '072-4604-%%%%%%' WHERE Name = 'HD Briefings Content (hdbrfcnt)' AND PartNumberID = '14'
UPDATE tblpartnumber SET DefaultPartNumber = '072-4606-%%%%%%' WHERE Name = 'HD Briefings Content CII' AND PartNumberID = '15'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7511-%%%%%%' WHERE Name = 'Audio / Video Briefings (avb)' AND PartNumberID = '16'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7512-%%%%%%' WHERE Name = 'Audio / Video Briefings CII' AND PartNumberID = '17'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7776-%%%%%%' WHERE Name = 'Briefings Config (brfcfg)' AND PartNumberID = '18'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7777-%%%%%%' WHERE Name = 'Briefings Config CII' AND PartNumberID = '19'
UPDATE tblpartnumber SET DefaultPartNumber = '811-5173-%%%%%%' WHERE Name = 'Blue Marble Map Package (bmp)' AND PartNumberID = '20'
UPDATE tblpartnumber SET DefaultPartNumber = '811-5174-%%%%%%' WHERE Name = 'Blue Marble Map Package CII' AND PartNumberID = '21'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7498-%%%%%%' WHERE Name = 'Configuration (mmcfgp)' AND PartNumberID = '22'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7499-%%%%%%' WHERE Name = 'Configuration CII' AND PartNumberID = '23'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7496-%%%%%%' WHERE Name = 'Content (mmcntp)' AND PartNumberID = '24'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7497-%%%%%%' WHERE Name = 'Content CII' AND PartNumberID = '25'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7500-%%%%%%' WHERE Name = 'Data (mmdbp)' AND PartNumberID = '26'
UPDATE tblpartnumber SET DefaultPartNumber = '811-7501-%%%%%%' WHERE Name = 'Data CII' AND PartNumberID = '27'
UPDATE tblpartnumber SET DefaultPartNumber = '811-5180-%%%%%%_(TZ)' WHERE Name = 'Timezone Database (mmcdp)' AND PartNumberID = '28'
UPDATE tblpartnumber SET DefaultPartNumber = '811-5181-%%%%%%_(TZ)' WHERE Name = 'Timezone Database CII' AND PartNumberID = '29'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2001-%%%%%%' WHERE Name = 'Content (swopcontent)' AND PartNumberID = '30'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2002-%%%%%%' WHERE Name = 'Timezone Database (customdata)' AND PartNumberID = '31'
UPDATE tblpartnumber SET DefaultPartNumber = '072-2559-%%%%%%' WHERE Name = 'Insets (minsets)' AND PartNumberID = '32'


IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE Name = 'CustomContent' AND FeatureSetID = 1)
BEGIN
	UPDATE tblFeatureSet SET value = 'true'
		WHERE Name = 'CustomContent' AND FeatureSetID = 1
END
IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE Name = 'CustomContent-Country' AND FeatureSetID = 1)
BEGIN
	UPDATE tblFeatureSet SET value = 'true'
		WHERE Name = 'CustomContent-Country' AND FeatureSetID = 1
END
IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE Name = 'CustomContent-Placenames' AND FeatureSetID = 1)
BEGIN
	UPDATE tblFeatureSet SET value = 'true'
		WHERE Name = 'CustomContent-Placenames' AND FeatureSetID = 1
END
IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE Name = 'CustomContent-Regions' AND FeatureSetID = 1)
BEGIN
	UPDATE tblFeatureSet SET value = 'true'
		WHERE Name = 'CustomContent-Regions' AND FeatureSetID = 1
END
IF EXISTS (SELECT 1 FROM tblFeatureSet WHERE Name = 'CustomContent-Airports' AND FeatureSetID = 1)
BEGIN
	UPDATE tblFeatureSet SET value = 'true'
		WHERE Name = 'CustomContent-Airports' AND FeatureSetID = 1
END

IF NOT EXISTS (SELECT 1 FROM tblConfigurationComponentType WHERE NAME = 'custom xml' AND ConfigurationComponentTypeID = 39)
BEGIN
	INSERT INTO tblConfigurationComponentType (ConfigurationComponentTypeID, Name, Description) VALUES (39, 'custom xml', 'custom xml')
END

DELETE FROM tblFeatureSet WHERE Name = 'Collins-Admin-ItemsList'
INSERT INTO tblFeatureSet (FeatureSetID, Name,Value,InputTypeID) VALUES (1, 'Collins-Admin-ItemsList', 'Populations,Placenames,Airports,World-Guide-Cities,Insets,Custom XML,ACARs Configuration,briefings configuration,briefings (non hd),Content HTSE 1280x720,Content ASXi3 Standard 3D,Content ASXi3 Aircraft Models,Content ASXi4/5 Aircraft Models,Content Mobile,Discrete Inputs,Flight Data Configuration,Flight Deck Controller Menu,Flight Phase Profile,Installation Scripts Venue Next,Installation Scripts Venue Hybrid,Map Package Blue Marble,Map Package Blue Marble Borderless,Mobile Configuration Platform,Site Identification,Sizes Configuration,System Configuration,Ticker Ads Configuration,Timezone Database,Resolution Map,font data,info spelling, mmobilecc configuration, FDC Map Menu list',3)

UPDATE tbltasktype SET ShouldShowInBuildDashboard = 0

UPDATE tbltasktype SET ShouldShowInBuildDashboard = 1 WHERE name IN('Export Product Database - Thales','Export Product Database - PAC3D','Export Product Database - AS4XXX','Export Product Database - CESHTSE','Venue Next','Venue Hybrid')

IF NOT EXISTS (SELECT 1 FROM tblConfigTables WHERE tblName='tblRliAeroPlaneTypes')
BEGIN
INSERT INTO tblConfigTables(tblName) VALUES ('tblRliAeroPlaneTypes')
END

UPDATE [dbo].[tblTaskType] SET ShouldShowInBuildDashboard=1, Description='Export Product Database - Thales' WHERE Name='Export Product Database - Thales'
UPDATE [dbo].[tblTaskType] SET ShouldShowInBuildDashboard=1,Description='Export Product Database - PAC3D' WHERE Name='Export Product Database - PAC3D'
UPDATE [dbo].[tblTaskType] SET ShouldShowInBuildDashboard=1,Description='Export Product Database - AS4XXX' WHERE Name='Export Product Database - AS4XXX'
UPDATE [dbo].[tblTaskType] SET ShouldShowInBuildDashboard=1,Description='Queued For Locking' WHERE Name='QueuedForLockCofiguration'
UPDATE [dbo].[tblTaskType] SET ShouldShowInBuildDashboard=1,Description='Merge Cofiguration' WHERE Name='MergCofiguration'
UPDATE [dbo].[tblTaskType] SET ShouldShowInBuildDashboard=1,Description='Venue Hybrid' WHERE Name='Venue Hybrid'
UPDATE [dbo].[tblTaskType] SET ShouldShowInBuildDashboard=1,Description='Export Product Database - CESHTSE' WHERE Name='Export Product Database - CESHTSE'
UPDATE [dbo].[tblTaskType] SET ShouldShowInBuildDashboard=1,Description='Venue Next' WHERE Name='Venue Next'

IF NOT EXISTs(SELECT 1 FROM tblFeatureSet WHERE Name = 'YourFlight-MaxNumOfParameters')
BEGIN
	INSERT INTO tblFeatureSet (FeatureSetID, Name,Value) VALUES (1, 'YourFlight-MaxNumOfParameters','6')
END

IF EXISTS(SELECT 1 FROM tblFeatureSet WHERE Name = 'CustomConfig-ViewsDisplayList')
BEGIN
	CREATE TABLE #CustomConfigViewsDisplayList (ID INT, FeatureSetID INT, Name NVARCHAR(MAX), value NVARCHAR(MAX), IsConfigurable INT,
	InputTypeID INT, KeyFeatureSetID INT)
	
	INSERT INTO #CustomConfigViewsDisplayList SELECT * FROM tblFeatureSet WHERE Name = 'CustomConfig-ViewsDisplayList'

	WHILE (SELECT COUNT (*) FROM #CustomConfigViewsDisplayList) > 0
	BEGIN
		DECLARE @Ids INT, @value NVARCHAR(MAX), @featureSetIDs INT
		SET @Ids = (SELECT TOP 1 ID FROM #CustomConfigViewsDisplayList)
		SET @featureSetIDs = (SELECT FeatureSetID FROM #CustomConfigViewsDisplayList WHERE ID = @Ids)
		SET @value = (SELECT value FROM #CustomConfigViewsDisplayList WHERE ID = @Ids)

		IF @value NOT LIKE '%,Your Flight, Broadcast%'
		BEGIN
			SET @value = CONCAT(@value, ',Your Flight, Broadcast')
			UPDATE tblFeatureSet SET value = @value WHERE Name = 'CustomConfig-ViewsDisplayList' AND FeatureSetID = @featureSetIDs
		END

		DELETE FROM #CustomConfigViewsDisplayList WHERE ID = @Ids
	END
	DROP TABLE IF EXISTS #CustomConfigViewsDisplayList
END

IF EXISTS(SELECT 1 FROM tblFeatureSet WHERE Name = 'CustomConfig-ViewsList')
BEGIN
	CREATE TABLE #CustomConfigViewsList (ID INT, FeatureSetID INT, Name NVARCHAR(MAX), value NVARCHAR(MAX), IsConfigurable INT,
	InputTypeID INT, KeyFeatureSetID INT)
	
	INSERT INTO #CustomConfigViewsList SELECT * FROM tblFeatureSet WHERE Name = 'CustomConfig-ViewsList'

	WHILE (SELECT COUNT (*) FROM #CustomConfigViewsList) > 0
	BEGIN
		DECLARE @viewId INT, @viewValue NVARCHAR(MAX), @viewFeatureSetID INT
		SET @viewId = (SELECT TOP 1 ID FROM #CustomConfigViewsList)
		SET @viewFeatureSetID = (SELECT FeatureSetID FROM #CustomConfigViewsList WHERE ID = @Ids)
		SET @viewValue = (SELECT value FROM #CustomConfigViewsList WHERE ID = @Ids)

		IF @value NOT LIKE '%,Your Flight, Broadcast%'
		BEGIN
			SET @viewValue = CONCAT(@viewValue, ',Your Flight, Broadcast')
			UPDATE tblFeatureSet SET value = @viewValue WHERE Name = 'CustomConfig-ViewsList' AND FeatureSetID = @viewFeatureSetID
		END
		
		DELETE FROM #CustomConfigViewsList WHERE ID = @viewId
	END
	DROP TABLE IF EXISTS #CustomConfigViewsList
END

IF EXISTS(SELECT 1 FROM tblconfigurationcomponenttype WHERE NAME = 'Venue Next scripts')
BEGIN
	UPDATE tblconfigurationcomponenttype SET Name = 'installation scripts venue next', Description = 'installation scripts venue next' WHERE Name = 'Venue Next scripts'
END
IF EXISTS(SELECT 1 FROM tblconfigurationcomponenttype WHERE NAME = 'Flight Phase configuration')
BEGIN
	UPDATE tblconfigurationcomponenttype SET Name = 'Flight Phase profile', Description = 'Flight Phase profile' WHERE Name = 'Flight Phase configuration'
END
IF EXISTS(SELECT 1 FROM tblconfigurationcomponenttype WHERE NAME = 'Flight deck configuration')
BEGIN
	UPDATE tblconfigurationcomponenttype SET Name = 'Flight deck controller menu', Description = 'Flight deck controller menu' WHERE Name = 'Flight deck configuration'
END
IF EXISTS(SELECT 1 FROM tblconfigurationcomponenttype WHERE NAME = 'ACARS Data configuration')
BEGIN
	UPDATE tblconfigurationcomponenttype SET Name = 'acars configuration', Description = 'acars configuration' WHERE Name = 'ACARS Data configuration'
END