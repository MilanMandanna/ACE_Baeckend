
DECLARE @ConfigurationDefID INT
SELECT @ConfigurationDefID = ConfigurationDefinitionID FROM tblConfigurationDefinitions 
							WHERE OutputTypeID IN (SELECT OutputTypeID FROM tblOutputTypes WHERE OutputTypeName IN ('Pac3D'))

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
		--tblFont
		IF NOT EXISTS (SELECT 1 FROM tblFontMap WHERE ConfigurationID = @ConfigID)
		BEGIN
			INSERT INTO tblFontMap (ConfigurationID, FontID, PreviousFontID, IsDeleted, Action)
			SELECT @ConfigID, ID, 0, 0, 'adding' FROM tblFont WHERE ID BETWEEN 936 AND 3016
		END
		--tblFontCategory
		IF NOT EXISTS (SELECT 1 FROM tblFontCategoryMap WHERE ConfigurationID = @ConfigID)
		BEGIN
			INSERT INTO tblFontCategoryMap (ConfigurationID, FontCategoryID, PreviousFontCategoryID, IsDeleted, Action)
			SELECT @ConfigID, FontCategoryID, 0, 0, 'adding' FROM tblFontCategory WHERE FontCategoryID BETWEEN 4047 AND 6368
		END
		--tblFontDefaultCategory
		IF NOT EXISTS (SELECT 1 FROM tblFontDefaultCategoryMap WHERE ConfigurationID = @ConfigID)
		BEGIN
			INSERT INTO tblFontDefaultCategoryMap (ConfigurationID, FontDefaultCategoryID, PreviousFontDefaultCategoryID, IsDeleted, Action)
			SELECT @ConfigID, FontDefaultCategoryID, 0, 0, 'adding' FROM tblFontDefaultCategory
		END
		--tblFontFamily
		IF NOT EXISTS (SELECT 1 FROM tblFontFamilyMap WHERE ConfigurationID = @ConfigID)
		BEGIN
			INSERT INTO tblFontFamilyMap (ConfigurationID, FontFamilyID, PreviousFontFamilyID, IsDeleted, Action)
			SELECT @ConfigID, FontFamilyID, 0, 0, 'adding' FROM tblFontFamily WHERE FontFamilyID = 25
		END
		--tblFontMarker
		IF NOT EXISTS (SELECT 1 FROM tblFontMarkerMap WHERE ConfigurationID = @ConfigID)
		BEGIN
			INSERT INTO tblFontMarkerMap (ConfigurationID, FontMarkerID, PreviousFontMarkerID, IsDeleted, Action)
			SELECT @ConfigID, FontMarkerID, 0, 0, 'adding' FROM tblFontMarker WHERE FontMarkerID BETWEEN 1 AND 7
		END
		--tblFontTextEffect
		IF NOT EXISTS (SELECT 1 FROM tblFontTextEffectMap WHERE ConfigurationID = @ConfigID)
		BEGIN
			INSERT INTO tblFontTextEffectMap (ConfigurationID, FontTextEffectID, PreviousFontTextEffectID, IsDeleted, Action)
			SELECT @ConfigID, FontTextEffectID, 0, 0, 'adding' FROM tblFontTextEffect
		END
		SET @cnt1 = @cnt1 + 1
	END
	SET @cnt = @cnt + 1
END
