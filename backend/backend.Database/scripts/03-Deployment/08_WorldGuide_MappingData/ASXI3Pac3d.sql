DECLARE @tempConfigDefs TABLE
( id INT IDENTITY,
  ConfigDefId INT
);
DELETE FROM @tempConfigDefs
INSERT INTO @tempConfigDefs
SELECT ConfigurationDefinitionID FROM tblConfigurationDefinitions 
							WHERE OutputTypeID IN (SELECT OutputTypeID FROM tblOutputTypes WHERE OutputTypeName IN ('Pac3D'))
DECLARE @cnt INT
DECLARE @cnt_total INT
DECLARE @ConfigurationDefID INT
SELECT @cnt = min(id) , @cnt_total = max(id) FROM @tempConfigDefs
--Loop all Configuration to add the mappings
WHILE @cnt <= @cnt_total
BEGIN
	SELECT @ConfigurationDefID = ConfigDefId FROM @tempConfigDefs WHERE id = @cnt
	DECLARE @tempConfigs TABLE
	( id INT IDENTITY,
	  ConfigId INT
	);
	DECLARE @cnt1 INT
	DECLARE @cnt_total1 INT
	DECLARE @ConfigID INT
	DELETE FROM @tempConfigs
	INSERT INTO @tempConfigs
	SELECT ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID = @ConfigurationDefID
	SELECT @cnt1 = min(id) , @cnt_total1 = max(id) FROM @tempConfigs
	--Loop all Configuration to add the mappings
	WHILE @cnt1 <= @cnt_total1
	BEGIN
		SELECT @ConfigID = ConfigId FROM @tempConfigs WHERE id = @cnt1
		DELETE FROM tblScreenSizeMap WHERE ConfigurationID = @ConfigID
		DELETE FROM tblWGContentMap WHERE ConfigurationID = @ConfigID
		DELETE FROM tblWGImageMap WHERE ConfigurationID = @ConfigID
		DELETE FROM tblWGtextMap WHERE ConfigurationID = @ConfigID
		DELETE FROM tblWGTypeMap WHERE ConfigurationID = @ConfigID
		DELETE FROM tblwgwcitiesMap WHERE ConfigurationID = @ConfigID
		--tblScreenSize
		INSERT INTO tblScreenSizeMap (ConfigurationID, ScreenSizeID, PreviousScreenSizeID, IsDeleted, Action)
		SELECT @ConfigID, ScreenSizeID, 0, 0, 'adding' FROM tblScreenSize 
		--tblWGContent
		INSERT INTO tblWGContentMap (ConfigurationID, WGContentID, PreviousWGContentID, IsDeleted, Action)
		SELECT @ConfigID, WGContentID, 0, 0, 'adding' FROM tblWGContent 
		--tblWGImage
		INSERT INTO tblWGImageMap (ConfigurationID, ImageID, PreviousImageID, IsDeleted, Action)
		SELECT @ConfigID, ID, 0, 0, 'adding' FROM tblWGImage
		--tblWGtext
		INSERT INTO tblWGtextMap (ConfigurationID, WGtextID, PreviousWGtextID, IsDeleted, Action)
		SELECT @ConfigID, WGtextID, 0, 0, 'adding' FROM tblWGtext 
		--tblWGType
		INSERT INTO tblWGTypeMap (ConfigurationID, WGTypeID, PreviousWGTypeID, IsDeleted, Action)
		SELECT @ConfigID, WGTypeID, 0, 0, 'adding' FROM tblWGType
		--tblwgwcities
		INSERT INTO tblwgwcitiesMap (ConfigurationID, CityID, PreviousCityID, IsDeleted, Action)
		SELECT @ConfigID, City_ID, 0, 0, 'adding' FROM tblwgwcities
		SET @cnt1 = @cnt1 + 1
	END
	SET @cnt = @cnt + 1
END
