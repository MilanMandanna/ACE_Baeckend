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
IN('Home','Settings','User Profile','Logout','Aircraft','User Administration', 'Administration', 'Collins Administrator - Only');

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