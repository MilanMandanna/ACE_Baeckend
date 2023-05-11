
IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'editable')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'editable','true'
INSERT INTO tblFeatureSet SELECT 2,'editable','true'
END

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-custom-configuration')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-custom-configuration','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-custom-configuration','false'
END

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-3d-trackline-content')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-3d-trackline-content','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-3d-trackline-content','false'
END

-- maps section

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-extended-tab-navigation')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-extended-tab-navigation','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-extended-tab-navigation','false'
END

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-tab-navigation')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-tab-navigation','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-tab-navigation','false'
END

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-fly-over-alerts')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-fly-over-alerts','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-fly-over-alerts','false'
END

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-3d-trackline-editor')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-3d-trackline-editor','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-3d-trackline-editor','false'
END

-- borders section
IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-3d-hong-kong')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-3d-hong-kong','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-3d-hong-kong','false'
END

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-broadcast')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-broadcast','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-broadcast','false'
END

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-hong-kong')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-hong-kong','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-hong-kong','false'
END

IF NOT EXISTS (SELECT FeatureSetID FROM tblFeatureSet WHERE Name = 'hide-html')
BEGIN
INSERT INTO tblFeatureSet SELECT 1,'hide-html','false'
INSERT INTO tblFeatureSet SELECT 2,'hide-html','false'
END


UPDATE tblFeatureSet SET Value = 'e3DPreFlight,e3DMidFlight,e3DZspace,e3DRli,e3DPanorama,e3DImage,e3DOverhead,e3DVideo,e3DFlightData,e3DRotatingPOI,e3DTotalRoute,e3DTimezone,e3DWorldClocks,e3DRliMecca,e3DHighestRes,e3DMakkah,e3DMiqat,eTickerImage,eTickerFd'
WHERE Name = 'script'

UPDATE tblFeatureSet SET Value = 'Flight Preview,Midflight,Global Zoom,Compass,Window Seat,Image,Overhead,Video,Flight Info,Points of Interest,Total Route,Timezone Globe,World Clocks,Makkah Compass,High Resolution,Makkah,Miqat,Ticker Image,Ticker Info'
WHERE Name = 'script-display'


IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE Name='MergCofiguration')
BEGIN
INSERT INTO tblTaskType(ID,Name,Description,AzureDefinitionID)
VALUES('C56A4180-65AA-42EC-A945-5FD21DEC0999','MergCofiguration','MergCofiguration',999);
END

IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE Name='QueuedForLockCofiguration')
BEGIN
INSERT INTO tblTaskType(ID,Name,Description,ShouldShowInBuildDashboard)
VALUES('723EBFBD-938E-419F-832F-49585ABD7FBF','QueuedForLockCofiguration','QueuedForLockCofiguration',1)

-- Update currently avaialable export db task type to be 1
UPDATE tblTaskType SET ShouldShowInBuildDashboard = 1
WHERE tblTaskType.ID IN ('ed0d1e4e-cb7f-4356-b366-33fe4fb50129','d693ad3a-4575-464d-ac5f-353a0db02146','b53297b7-8c0c-4452-9d58-393973558ffd','0d67043d-e490-448e-aeb6-399cbe2f51b6','00b9d873-5a19-43d7-b085-a7444a5babf2','dc1610ba-e8b9-43ba-91f4-f56685820b9e')
END


IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE Name='Venue Next')
BEGIN
INSERT INTO tblTaskType(ID,Name,Description,ShouldShowInBuildDashboard)
VALUES('C9B497C1-6400-418F-86A1-B15CF14C9218','Venue Next','Venue Next',1);
END


IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%discrete inputs%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',discrete inputs') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='discrete inputs')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'discrete inputs','Discrete input spec for the ArincD process' FROM tblConfigurationComponentType 
END
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*inserted the values to tblPartNumberCollection,tblPartNumber,tblConfigurationDefinitionPartNumber */

/*tblPartNumberCollection*/

IF NOT EXISTS (SELECT Name FROM tblPartNumberCollection WHERE Name='Venue Next')
BEGIN
INSERT INTO tblPartNumberCollection VALUES(1,'Venue Next','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5')
END

IF NOT EXISTS (SELECT Name FROM tblPartNumberCollection WHERE Name='Venue Hybrid')
BEGIN
INSERT INTO tblPartNumberCollection VALUES(2,'Venue Hybrid','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5')
END

IF NOT EXISTS (SELECT Name FROM tblPartNumberCollection WHERE Name='eConnect')
BEGIN
INSERT INTO tblPartNumberCollection VALUES( 3,'eConnect','Collection of part numbers used only for the eConnect system')
END

/*tblPartNumber*/
IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 1)
BEGIN
INSERT INTO tblPartNumber VALUES(1,1,'HD Briefings Config (hdbrfcfg)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-4599-%%%%%%_(VV)',1)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 2)
BEGIN
INSERT INTO tblPartNumber VALUES(2,1,'HD Briefings Config CII','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-4601-%%%%%%_(VV)',2)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 3)
BEGIN
INSERT INTO tblPartNumber VALUES(3,1,'Customer Content (mcc)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-4603-%%%%%%_(VV)',3)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 4)
BEGIN
INSERT INTO tblPartNumber VALUES(4,1,'HD Briefings Content CII','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-4605-%%%%%%_(VV)',4)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 5)
BEGIN
INSERT INTO tblPartNumber VALUES(5,1,'Customer Content (mcc)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-2559-%%%%%%_(VV)',5)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 6)
BEGIN
INSERT INTO tblPartNumber VALUES(6,1,'Configuration (mcfg)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-2559-%%%%%%_(VV)',6)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 7)
BEGIN
INSERT INTO tblPartNumber VALUES(7,1,'Content (mcnt)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-2559-%%%%%%_(VV)',7)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 8)
BEGIN
INSERT INTO tblPartNumber VALUES(8,1,'Data (mdata)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-2559-%%%%%%_(VV)',8)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 9)
BEGIN
INSERT INTO tblPartNumber VALUES(9,1,'Insets (minsets)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-2559-%%%%%%_(VV)',9)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 10)
BEGIN
INSERT INTO tblPartNumber VALUES(10,1,'Mobile Configuration (mmobilecc)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-2559-%%%%%%_(VV)',10)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 11)
BEGIN
INSERT INTO tblPartNumber VALUES(11,1,'Timezone Database (mtz)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-3222-%%%%%%_(VV)',11)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 12)
BEGIN
INSERT INTO tblPartNumber VALUES(12,1,'HD Briefings Config (hdbrfcfg)','Collection of part numbers used for Venue systems that consist of ECUs and DEUs running only ASXi4/5','072-4600-%%%%%%_(VV)',12)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 13)
BEGIN
INSERT INTO tblPartNumber VALUES(13,2,'HD Briefings Config CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','072-4602-%%%%%%_(VV)',13)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 14)
BEGIN
INSERT INTO tblPartNumber VALUES(14,2,'HD Briefings Content (hdbrfcnt)','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','072-4604-%%%%%%_(VV)',14)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 15)
BEGIN
INSERT INTO tblPartNumber VALUES(15,2,'HD Briefings Content CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','072-4606-%%%%%%_(VV)',15)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 16)
BEGIN
INSERT INTO tblPartNumber VALUES(16,2,'Audio / Video Briefings (avb)','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7511-%%%%%%_(VV)',16)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 17)
BEGIN
INSERT INTO tblPartNumber VALUES(17,2,'Audio / Video Briefings CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7512-%%%%%%_(VV)',17)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 18)
BEGIN
INSERT INTO tblPartNumber VALUES(18,2,'Briefings Config (brfcfg)','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7776-%%%%%%_(VV)',18) 
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 19)
BEGIN
INSERT INTO tblPartNumber VALUES(19,2,'Briefings Config CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7777-%%%%%%_(VV)',19)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 20)
BEGIN
INSERT INTO tblPartNumber VALUES(20,2,'Blue Marble Map Package (bmp)','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-5173-%%%%%%_(VV)',20)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 21)
BEGIN
INSERT INTO tblPartNumber VALUES(21,2,'Blue Marble Map Package CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-5174-%%%%%%_(VV)',21)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 22)
BEGIN
INSERT INTO tblPartNumber VALUES(22,2,'Configuration (mmcfgp)','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7498-%%%%%%_(VV)',22)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 23)
BEGIN
INSERT INTO tblPartNumber VALUES(23,2,'Configuration CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7499-%%%%%%_(VV)',23)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 24)
BEGIN
INSERT INTO tblPartNumber VALUES(24,2,'Content (mmcntp)','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7496-%%%%%%_(VV)',24)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 25)
BEGIN
INSERT INTO tblPartNumber VALUES(25,2,'Content CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7497-%%%%%%_(VV)',25)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 26)
BEGIN
INSERT INTO tblPartNumber VALUES(26,2,'Data (mmdbp)','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7500-%%%%%%_(VV)',26)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 27)
BEGIN
INSERT INTO tblPartNumber VALUES(27,2,'Data CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-7501-%%%%%%_(VV)',27)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 28)
BEGIN
INSERT INTO tblPartNumber VALUES(28,2,'Timezone Database (mmcdp)','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-5180-%%%%%%_(TZ)_(VV)',28)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 29)
BEGIN
INSERT INTO tblPartNumber VALUES(29,2,'Timezone Database CII','Collection of part numbers used for Venue systems that consist of HDAVs, ECUs, and DEUs running a combination of ASXi3/4/5','811-5181-%%%%%%_(TZ)_(VV)',29)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 30)
BEGIN
INSERT INTO tblPartNumber VALUES(30,3,'Content (swopcontent)','Collection of part numbers used only for the eConnect system.','072-2001-%%%%%%_(VV)',30)
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 31)
BEGIN
INSERT INTO tblPartNumber VALUES(31,3,'Timezone Database (customdata)','Collection of part numbers used only for the eConnect system.','072-2002-%%%%%%_(VV)',31)
END

--Update proper text for Venue Next PartNumber Collection as per https://alm.rockwellcollins.com/wiki/display/ASXIW/Partnumber+Collection
IF EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 3)
BEGIN
UPDATE tblPartNumber SET Name = 'HD Briefings Content (hdbrfcnt)' WHERE PartNumberID = 3
END

/*tblConfigurationDefinitionPartNumber*/
IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 1)
BEGIN
INSERT INTO tblConfigurationDefinitionPartNumber VALUES(1,1,'')
END

IF NOT EXISTS (SELECT PartNumberID FROM tblPartNumber WHERE PartNumberID = 2)
BEGIN
INSERT INTO tblConfigurationDefinitionPartNumber VALUES(2,2,'')
END

--Non-HD variants of the briefings
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%briefings (non hd)%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',briefings (non hd)') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='briefings (non hd)')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'briefings (non hd)','Non-HD variants of the briefings' FROM tblConfigurationComponentType 
END


--The base Blue Marble map package
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%map package blue marble%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',map package blue marble') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='map package blue marble')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'map package blue marble','The base Blue Marble map package' FROM tblConfigurationComponentType 
END


--The base Blue Marble map package without borders
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%map package borderless blue marble%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',map package borderless blue marble') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='map package borderless blue marble')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'map package borderless blue marble','The base Blue Marble map package without borders' FROM tblConfigurationComponentType 
END

--1280x720 resolution content for the HTSE / BDU
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%content htse 1280x720%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',content htse 1280x720') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='content htse 1280x720')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'content htse 1280x720','1280x720 resolution content for the HTSE / BDU' FROM tblConfigurationComponentType 
END

--3D content for the HTSE / BDU
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%content asxi3 standard 3d%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',content asxi3 standard 3d') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='content asxi3 standard 3d')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'content asxi3 standard 3d','3D content for the HTSE / BDU' FROM tblConfigurationComponentType 
END

--Aircraft models for the ASXi3 software
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%content asxi3 aircraft models%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',content asxi3 aircraft models') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='content asxi3 aircraft models')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'content asxi3 aircraft models','Aircraft models for the ASXi3 software' FROM tblConfigurationComponentType 
END

--Aircraft models for the ASXi 4/5 software
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%content asx4/5 aircraft models%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',content asx4/5 aircraft models') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='content asx4/5 aircraft models')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'content asx4/5 aircraft models','Aircraft models for the ASXi 4/5 software' FROM tblConfigurationComponentType 
END

--Platform installation scripts for the Venue Classic platform
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%installation scripts venue hybrid%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',installation scripts venue hybrid') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='installation scripts venue hybrid')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'installation scripts venue hybrid','Platform install scripts for Venue Classic' FROM tblConfigurationComponentType 
END

IF NOT EXISTS (SELECT 1 FROM tblOutputTypes WHERE OutputTypeName='Venue Next')
BEGIN
INSERT INTO tblOutputTypes(OutputTypeID,OutputTypeName,PartNumberCollectionID) SELECT MAX(OutputTypeID)+1,'Venue Next',NULL FROM tblOutputTypes
END

--Flight Deck Control Map Menu list config
IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%FDC Map Menu list%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',FDC Map Menu list') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='FDC Map Menu list')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'FDC Map Menu list','FDC Map Menu list' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Site Identification configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Site Identification configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Site Identification configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Site Identification configuration','Site Identification configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%System Configuraiton%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',System Configuraiton') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='System Configuraiton')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'System Configuraiton', 'System Configuraiton' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Flight Data configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Flight Data configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Flight Data configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Flight Data configuration', 'Flight Data configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Timezone Database configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Timezone Database configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Timezone Database configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Timezone Database configuration','Timezone Database configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Flight Phase configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Flight Phase configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Flight Phase configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Flight Phase configuration','Flight Phase configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%ACARS Data configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',ACARS Data configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='ACARS Data configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'ACARS Data configuration','ACARS Data configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Sizes configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Sizes configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Sizes configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Sizes configuration','Sizes configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Content 3D configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Content 3D configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Content 3D configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Content 3D configuration','Content 3D configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Content Mobile configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Content Mobile configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Content Mobile configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Content Mobile configuration','Content Mobile configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Venue Next scripts%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Venue Next scripts') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Venue Next scripts')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Venue Next scripts','Venue Next scripts' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%CES scripts%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',CES scripts') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='CES scripts')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'CES scripts','CES scripts' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Resolution Map configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Resolution Map configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Resolution Map configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Resolution Map configuration','Resolution Map configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Briefings configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Briefings configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Briefings configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Briefings configuration','Briefings configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%Flight Deck configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',Flight Deck configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='Flight Deck configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'Flight Deck configuration','Flight Deck configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%mobile configuration platform%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',mobile configuration platform') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='mobile configuration platform')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'mobile configuration platform','mobile configuration platform' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%content 3d aircraft models%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',content 3d aircraft models') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='content 3d aircraft models')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'content 3d aircraft models','content 3d aircraft models' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%ticker ads configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',ticker ads configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='ticker ads configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'ticker ads configuration','ticker ads configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblFeatureSet WHERE VALUE LIKE '%mmobilecc configuration%' AND [Name] = 'collins-admin-items')
BEGIN
UPDATE tblFeatureSet SET [Value] = CONCAT([Value],',mmobilecc configuration') WHERE [Name] = 'collins-admin-items';
END
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='mmobilecc configuration')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'mmobilecc configuration','mmobilecc configuration' FROM tblConfigurationComponentType 
END

IF NOT EXISTS(SELECT 1 FROM tblTaskType WHERE NAME = 'Build Modlist Json' AND ID = '3FF21C44-194A-4139-8E65-0BC2A56516CA')
BEGIN
	INSERT INTO tblTaskType (ID, Name, Description, ShouldShowInBuildDashboard) values ('3FF21C44-194A-4139-8E65-0BC2A56516CA', 'Build Modlist Json', 'Build Modlist Json', 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE Name='PerformDataMerge')
BEGIN
INSERT INTO tblTaskType(ID,Name,Description,AzureDefinitionID)
VALUES('BDECA6A4-9A74-4861-BC3E-5659257952FA','PerformDataMerge','PerformDataMerge',999);
END

IF NOT EXISTS (SELECT 1 FROM tblTaskType WHERE Name='UI Merge Configuration' AND ID = '75A1B8F0-E0DB-4A61-86D3-8557ED46A772')
BEGIN
INSERT INTO tblTaskType(ID,Name,Description,ShouldShowInBuildDashboard)
VALUES('75A1B8F0-E0DB-4A61-86D3-8557ED46A772','UI Merge Configuration','Merge Configuration from UI',0);
END

IF NOT EXISTS (SELECT 1 FROM tblFeatureSet WHERE Name='ViewsMenu' AND FeatureSetID = 1)
BEGIN
INSERT INTO tblFeatureSet (FeatureSetID, Name, Value)
VALUES (1, 'ViewsMenu', 'Auto Play, Flight Preview, Total Route, Landscape, Overhead, Compass, World Clocks, Time Zone, Global Zoom, Diagnostics, Flight Data, Panorama, Command Center, Makkah, Flight Info, Rotating POI')
END

--Add 'Insets' ConfigurationComponentType
IF NOT EXISTS(SELECT 1 FROM tblConfigurationComponentType WHERE Name='map insets')
BEGIN
INSERT INTO tblConfigurationComponentType(ConfigurationComponentTypeID, Name,Description)
SELECT COALESCE(MAX(ConfigurationComponentTypeID),0)+1,'map insets','Map Insets' FROM tblConfigurationComponentType 
END

IF EXISTS (SELECT 1 FROM tblConfigTables WHERE tblName IN 
('tblAirportInfo','tblRegionSpelling','tblCountry','tblCountrySpelling','tblCoverageSegment','tblSpelling','tblGeoRef','tblAppearance'))
BEGIN
	UPDATE tblConfigTables SET IsUsedForMergeConfiguration = 1 WHERE tblName IN 
	('tblAirportInfo','tblRegionSpelling','tblCountry','tblCountrySpelling','tblCoverageSegment','tblSpelling','tblGeoRef','tblAppearance') 
	AND IsUsedForMergeConfiguration = 0
END

IF NOT EXISTS (SELECT 1 FROM tblFeatureSet WHERE Name = 'Modlist-resolutions')
BEGIN
	INSERT INTO tblFeatureSet (FeatureSetID, Name, Value) VALUES (1, 'Modlist-resolutions', '15360, 7680, 3840, 1920, 960, 480, 240, 120, 60, 30')
END
