DROP TABLE IF EXISTS #tblanguage;
CREATE TABLE #tblanguage (
  LanguageID int NOT NULL default '0',
  Name varchar(30) default NULL,
  TwoLetterID varchar(2) default NULL,
  ThreeLetterID varchar(3) default NULL,
  HorizontalOrder int default NULL,
  HorizontalScroll int default NULL,
  VerticalOrder int default NULL,
  VerticalScroll int default NULL
) 

--
-- Dumping data for table asxnet.tblanguage
--

/*!40000 ALTER TABLE tblanguage DISABLE KEYS */;
INSERT INTO #tblanguage VALUES (0,'DEFAULT','NA','NA',1,1,1,1),(1,'ENGLISH','EN','ENG',1,1,1,1),(2,'FRENCH','FR','FRA',1,1,1,1),(3,'GERMAN','DE','DEU',1,1,1,1),(4,'SPANISH','ES','SPA',1,1,1,1),(5,'DUTCH','NL','NLD',1,1,1,1),(6,'ITALIAN','IT','ITA',1,1,1,1),(7,'GREEK','EL','ELL',0,0,0,0),(8,'JAPANESE','JA','JPN',0,0,0,0),(9,'TRAD_CHINESE','ZH','ZHO',1,2,3,2),(10,'KOREAN','KO','KOR',0,0,0,0),(11,'INDONESIAN','ID','IND',0,0,0,0),(12,'ARABIC','AR','ARA',2,2,2,1),(13,'TURKISH','TR','TUR',0,0,0,0),(14,'MALAY','MS','MSA',0,0,0,0),(15,'FINNISH','FI','FIN',1,1,1,1),(16,'HINDI','HI','HIN',0,0,0,0),(17,'RUSSIAN','RU','RUS',1,1,1,1),(18,'PORTUGUESE','PT','POR',1,1,1,1),(19,'THAI','TH','THA',1,1,1,1),(20,'ROMANIAN','RO','RON',1,1,1,1),(21,'SERBIAN','SR','SRP',0,0,0,0),(22,'SWEDISH','SV','SVE',1,1,1,1),(23,'HUNGARIAN','HU','HUN',1,1,1,1),(24,'HEBREW','HE','HEB',2,2,2,1),(25,'POLISH','PL','POL',1,1,1,1),(26,'SIMP_CHINESE','HK','ZHK',1,2,3,2),(27,'VIETNAMESE','VI','VIE',1,1,1,1),(28,'SAMOAN','SM','SMO',1,1,1,1),(29,'TONGAN','TO','TON',1,1,1,1),(30,'CZECH','CS','CES',1,1,1,1),(31,'DANISH','DA','DAN',1,1,1,1),(32,'ICELANDIC','IS','ISL',1,1,1,1),(33,'DARI','DI','PRS',2,2,2,1),(44,'LATIN KAZAKH','LK','LKK',1,1,1,1);
/*!40000 ALTER TABLE tblanguage ENABLE KEYS */;
--select * from #tblanguage
 --SELECT THE CONFIG IDs for the product CES and map it to all config ids

 DECLARE @tempConfigDefs TABLE
( id INT IDENTITY,
  ConfigDefId INT
);
DELETE FROM @tempConfigDefs
INSERT INTO @tempConfigDefs
SELECT ConfigurationDefinitionID FROM tblConfigurationDefinitions 
							WHERE OutputTypeID IN (SELECT OutputTypeID FROM tblOutputTypes WHERE OutputTypeName IN ('Thales2D'))
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
	SELECT ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID = 2
	SELECT @cnt1 = min(id) , @cnt_total1 = max(id) FROM @tempConfigs
	--Loop all Configuration to add the mappings
	WHILE @cnt1 <= @cnt_total1
	BEGIN
		SELECT @ConfigID = ConfigId FROM @tempConfigs WHERE id = @cnt1

			DELETE FROM tbllanguagesMap WHERE ConfigurationID = @ConfigID
			INSERT INTO tbllanguagesMap (ConfigurationID, LanguageID, PreviousLanguageID, IsDeleted, Action)
			SELECT @ConfigID,B.ID,0,0,'adding' FROM #tblanguage A INNER JOIN tblLanguages B ON A.Name=B.Name
		
		SET @cnt1 = @cnt1 + 1
	END
	SET @cnt = @cnt + 1
END

