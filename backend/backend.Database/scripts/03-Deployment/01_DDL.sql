IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'PxSize'
          AND Object_ID = Object_ID(N'dbo.tblFont'))
BEGIN
ALTER TABLE tblFont ADD PxSize INT NULL
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'TextEffectId'
          AND Object_ID = Object_ID(N'dbo.tblFont'))
BEGIN
ALTER TABLE tblFont ADD TextEffectId INT NULL
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'Resolution'
          AND Object_ID = Object_ID(N'dbo.tblFontCategory'))
BEGIN
ALTER TABLE tblFontCategory ADD Resolution INT NOT NULL DEFAULT 0
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'SphereFontId'
          AND Object_ID = Object_ID(N'dbo.tblFontCategory'))
BEGIN
ALTER TABLE tblFontCategory ADD SphereFontId INT NULL
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AtlasMarkerId'
          AND Object_ID = Object_ID(N'dbo.tblFontCategory'))
BEGIN
ALTER TABLE tblFontCategory ADD AtlasMarkerId INT NULL
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'SphereMarkerId'
          AND Object_ID = Object_ID(N'dbo.tblFontCategory'))
BEGIN
ALTER TABLE tblFontCategory ADD SphereMarkerId INT NULL
END

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGeorefIdCategoryType]') AND type in (N'U'))
DROP TABLE [dbo].[tblGeorefIdCategoryType]
GO

CREATE TABLE [dbo].[tblGeorefIdCategoryType](
       [GeoRefIdCatTypeId] [int] NOT NULL,
       [Description] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
       [GeoRefIdCatTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--Make FontDefaultCategoryID column as Identity field similar to other data tables.
--As we cannot alter existing table column to Identity field, creates new table with Identity field, copys existing table data into it and drops the existing table.
IF (SELECT COLUMNPROPERTY(OBJECT_ID('tblFontDefaultCategory'),'FontDefaultCategoryID','IsIdentity')) = 0
BEGIN
	--Create Table with Identity Column
	CREATE TABLE dbo.Tmp_tblFontDefaultCategory
		(
		  FontDefaultCategoryID INT NOT NULL IDENTITY(1,1),
		  GeoRefIdCatTypeId INT NOT NULL DEFAULT '0',
		  Resolution INT NOT NULL DEFAULT '0',
		  FontId INT DEFAULT NULL,
		  SphereFontId INT DEFAULT NULL,
		  MarkerId INT DEFAULT NULL,
		  AtlasMarkerId INT DEFAULT NULL,
		  SphereMarkerId INT DEFAULT NULL
		)
	ON  [PRIMARY]
	--Set IDENTITY_INSERT ON for the table
	SET IDENTITY_INSERT dbo.Tmp_tblFontDefaultCategory ON
	--Populate the table
	IF EXISTS (SELECT * FROM dbo.tblFontDefaultCategory) 
	BEGIN
		INSERT INTO dbo.Tmp_tblFontDefaultCategory ( FontDefaultCategoryID, GeoRefIdCatTypeId,Resolution,FontId,SphereFontId,MarkerId,AtlasMarkerId,SphereMarkerId )
		SELECT  FontDefaultCategoryID, GeoRefIdCatTypeId,Resolution,FontId,SphereFontId,MarkerId,AtlasMarkerId,SphereMarkerId FROM    dbo.tblFontDefaultCategory TABLOCKX
	END
	--Set IDENTITY_INSERT OFF
	SET IDENTITY_INSERT dbo.Tmp_tblFontDefaultCategory OFF
	--Drop Existing contraints and table
	ALTER TABLE dbo.tblFontDefaultCategoryMap DROP CONSTRAINT FK_tblFontDefaultCategoryMap_tblFontDefaultCategory
	ALTER TABLE dbo.tblFontDefaultCategory DROP CONSTRAINT PK_tblFontDefaultCategory
	DROP TABLE dbo.tblFontDefaultCategory
	--Rename New table with Existing table name
	Exec sp_rename 'Tmp_tblFontDefaultCategory', 'tblFontDefaultCategory'
	--Add the existing Contraints to new table
	ALTER TABLE [dbo].[tblFontDefaultCategory] 
	 ADD CONSTRAINT [PK_tblFontDefaultCategory]
		PRIMARY KEY CLUSTERED ([FontDefaultCategoryID] ASC)
	ALTER TABLE [dbo].[tblFontDefaultCategoryMap] ADD CONSTRAINT [FK_tblFontDefaultCategoryMap_tblFontDefaultCategory]
		FOREIGN KEY ([FontDefaultCategoryID]) REFERENCES [dbo].[tblFontDefaultCategory] ([FontDefaultCategoryID]) ON DELETE No Action ON UPDATE No Action
	ALTER TABLE [dbo].[tblFontDefaultCategory] ADD CONSTRAINT [FK_tblFontDefaultCategory_tblfontmarker_01]
		FOREIGN KEY ([AtlasMarkerId]) REFERENCES [dbo].[tblfontmarker] ([FontMarkerId]) ON DELETE No Action ON UPDATE No Action
	ALTER TABLE [dbo].[tblFontDefaultCategory] ADD CONSTRAINT [FK_tblFontDefaultCategory_tblfontmarker_02]
		FOREIGN KEY ([SphereMarkerId]) REFERENCES [dbo].[tblfontmarker] ([FontMarkerId]) ON DELETE No Action ON UPDATE No Action
	ALTER TABLE [dbo].[tblFontDefaultCategory] ADD CONSTRAINT [FK_tblFontDefaultCategory_tblfontmarker_03]
		FOREIGN KEY ([MarkerId]) REFERENCES [dbo].[tblfontmarker] ([FontMarkerId]) ON DELETE No Action ON UPDATE No Action
	ALTER TABLE [dbo].[tblFontDefaultCategory] ADD CONSTRAINT [FK_tblFontDefaultCategory_tblFont]
		FOREIGN KEY ([FontID]) REFERENCES [dbo].[tblFont] ([ID]) ON DELETE No Action ON UPDATE No Action
	
	--Update the identity seed
	DBCC CHECKIDENT('tblFontDefaultCategory');
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'Text_EP'
          AND Object_ID = Object_ID(N'dbo.tblwgtext'))
BEGIN
ALTER TABLE tblwgtext ADD Text_EP NVARCHAR(MAX) NULL
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'Text_SP'
          AND Object_ID = Object_ID(N'dbo.tblwgtext'))
BEGIN
ALTER TABLE tblwgtext ADD Text_SP NVARCHAR(MAX) NULL
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'Text_NO'
          AND Object_ID = Object_ID(N'dbo.tblwgtext'))
BEGIN
ALTER TABLE tblwgtext ADD Text_NO NVARCHAR(MAX) NULL
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'Text_TK'
          AND Object_ID = Object_ID(N'dbo.tblwgtext'))
BEGIN
ALTER TABLE tblwgtext ADD Text_TK NVARCHAR(MAX) NULL
END
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'Text_LK'
          AND Object_ID = Object_ID(N'dbo.tblwgtext'))
BEGIN
ALTER TABLE tblwgtext ADD Text_LK NVARCHAR(MAX) NULL
END
IF OBJECT_ID('tblwgwcities') IS NULL
BEGIN
CREATE TABLE tblwgwcities (
  city_id INT NOT NULL DEFAULT '0',
  georefid INT DEFAULT NULL,
  PRIMARY KEY  (city_id)
)
END
IF OBJECT_ID('tblwgwcitiesMap') IS NULL
BEGIN
CREATE TABLE [dbo].[tblwgwcitiesMap]
(
	[ConfigurationID] int NULL,
	[CityID] int NULL,
	[PreviousCityID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
END

IF NOT EXISTS(SELECT 1 FROM sys.columns  WHERE Name = N'TopLevelPartNumber' AND Object_ID = Object_ID(N'dbo.tblProducts'))
BEGIN
ALTER TABLE dbo.tblProducts ADD TopLevelPartNumber VARCHAR(255)
END
GO

IF (OBJECT_ID('dbo.FK_tblwgwcitiesMap_tblConfigurations', 'F') IS NULL)
BEGIN
 ALTER TABLE [dbo].[tblwgwcitiesMap] ADD CONSTRAINT [FK_tblwgwcitiesMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
END
GO

IF (OBJECT_ID('dbo.FK_tblwgwcitiesMap_tblwgwcities', 'F') IS NULL)
BEGIN
ALTER TABLE [dbo].[tblwgwcitiesMap] ADD CONSTRAINT [FK_tblwgwcitiesMap_tblwgwcities]
	FOREIGN KEY ([CityID]) REFERENCES [dbo].[tblwgwcities] ([city_id]) ON DELETE Cascade ON UPDATE No Action
END

GO

DROP TABLE if exists [dbo].[tblTempAircraftPartnumber]
CREATE TABLE [dbo].[tblTempAircraftPartnumber](	[ProductConfigurationDefinitionId] int NULL,	[TailNumber] nvarchar(255) NULL,	[PartnumberId] int NULL,	[Value] varchar(255) NULL)

GO

DROP TABLE IF EXISTS tblMenus
IF (OBJECT_ID('dbo.FK_tblMenuClaims_tblUserMenus', 'F') IS NOT NULL)
BEGIN
ALTER TABLE dbo.[tblMenuClaims] DROP CONSTRAINT FK_tblMenuClaims_tblUserMenus
TRUNCATE TABLE tblMenuClaims 
TRUNCATE TABLE tblUserMenus 
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblUserMenus]') AND type in (N'U'))
DROP TABLE [dbo].[tblUserMenus]
GO

CREATE TABLE [dbo].[tblUserMenus](
	MenuId INT IDENTITY,
	MenuName NVARCHAR(300),
	Description NVARCHAR(500),
	ParentMenuId INT DEFAULT NULL,
	MenuClass NVARCHAR(500),
	MinimizedMenuClass NVARCHAR(500),
	RouteURL NVARCHAR(500),
	IsConfigIdRequired BIT,
	isEnabled BIT
 CONSTRAINT [PK_tblMenus] PRIMARY KEY CLUSTERED 
(
	MenuId ASC
))
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblMenuClaims]') AND type in (N'U'))
DROP TABLE [dbo].[tblMenuClaims]
GO

CREATE TABLE [dbo].[tblMenuClaims](
	[ID] INT IDENTITY NOT NULL,
	[MenuID] INT NULL,
	[ClaimID] UNIQUEIDENTIFIER NULL,
	[AccessLevel] INT NOT NULL
 CONSTRAINT [PK_tblMenuClaims] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
))
GO

IF (OBJECT_ID('dbo.FK_tblMenuClaims_tblUserMenus', 'F') IS NULL)
BEGIN
ALTER TABLE [dbo].[tblMenuClaims] ADD CONSTRAINT [FK_tblMenuClaims_tblUserMenus]
	FOREIGN KEY ([MenuID]) REFERENCES [dbo].[tblUserMenus] ([MenuId]) ON DELETE Cascade ON UPDATE No Action
END
GO

ALTER TABLE [dbo].[tblConfigurationDefinitions] DROP CONSTRAINT if exists [FK_tblConfigurationDefinitions_tblOutputTypes]

TRUNCATE TABLE [dbo].[tblOutputTypes]

ALTER TABLE [dbo].[tblConfigurationDefinitions]  WITH NOCHECK ADD  CONSTRAINT [FK_tblConfigurationDefinitions_tblOutputTypes] FOREIGN KEY([OutputTypeID])
REFERENCES [dbo].[tblOutputTypes] ([OutputTypeID])
GO

--Add FeatureSet InputType table
IF (OBJECT_ID('dbo.tblFeatureSetInputType') IS  NOT NULL)
BEGIN
	IF (OBJECT_ID('dbo.FK_tblFeatureSet_tblFeatureSetInputType') IS NOT NULL)
	BEGIN
		ALTER TABLE [dbo].[tblFeatureSet] DROP CONSTRAINT [FK_tblFeatureSet_tblFeatureSetInputType]
	END
	DROP TABLE dbo.tblFeatureSetInputType
END
GO

CREATE TABLE dbo.tblFeatureSetInputType
(
	InputTypeID INT NOT NULL,
	Name VARCHAR(255),
	CONSTRAINT [PK_tblFeatureSetInputType] PRIMARY KEY CLUSTERED ([InputTypeID] ASC)
)

--FeatureSet Input Types
INSERT INTO tblFeatureSetInputType (InputTypeID, Name)
VALUES
(1, 'textbox'),
(2, 'checkbox'),
(3, 'dropdown')

--Add Identity field to tblFeatureSet table
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ID'
          AND Object_ID = Object_ID(N'dbo.tblFeatureSet'))
BEGIN
	--Create Table with Identity Column
	CREATE TABLE dbo.Tmp_tblFeatureSet
		(
		  ID INT NOT NULL IDENTITY(1,1),
		  FeatureSetID INT NOT NULL,
		  Name VARCHAR(255),
		  value TEXT
		)
	ON  [PRIMARY]

	--Populate the table
	IF EXISTS (SELECT * FROM dbo.tblFeatureSet) 
	BEGIN
		INSERT INTO dbo.Tmp_tblFeatureSet ( FeatureSetID, Name, value )
		SELECT FeatureSetID, Name, value FROM dbo.tblFeatureSet TABLOCKX
	END

	DROP TABLE dbo.tblFeatureSet
	--Rename New table with Existing table name
	Exec sp_rename 'Tmp_tblFeatureSet', 'tblFeatureSet'
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'IsConfigurable'
          AND Object_ID = Object_ID(N'dbo.tblFeatureSet'))
BEGIN
	ALTER TABLE tblFeatureSet
	ADD IsConfigurable BIT NOT NULL 
	CONSTRAINT DF_tblFeatureSet_IsConfigurble
	DEFAULT (1)
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'InputTypeID'
          AND Object_ID = Object_ID(N'dbo.tblFeatureSet'))
BEGIN
	ALTER TABLE tblFeatureSet ADD InputTypeID INT NOT NULL CONSTRAINT DF_tblFeatureSet_InputTypeID DEFAULT (1)
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'KeyFeatureSetID'
          AND Object_ID = Object_ID(N'dbo.tblFeatureSet'))
BEGIN
	ALTER TABLE tblFeatureSet ADD KeyFeatureSetID INT NULL
END
GO

IF (OBJECT_ID('dbo.FK_tblFeatureSet_tblFeatureSetInputType', 'F') IS NULL)
BEGIN
ALTER TABLE [dbo].[tblFeatureSet] ADD CONSTRAINT [FK_tblFeatureSet_tblFeatureSetInputType]
	FOREIGN KEY ([InputTypeID]) REFERENCES [dbo].[tblFeatureSetInputType] ([InputTypeID]) ON DELETE Cascade ON UPDATE No Action
END
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'DetailedStatus'
          AND Object_ID = Object_ID(N'dbo.tblTasks'))
BEGIN
	ALTER TABLE tblTasks ALTER COLUMN DetailedStatus NVARCHAR(MAX)
END



IF OBJECT_ID('tblTempFontsCategory') IS NULL
BEGIN
CREATE TABLE [dbo].[tblTempFontsCategory]
(
    FontCategoryID int identity(1,1),
    GeoRefIdCatTypeID int,
    LanguageID int,
    FontID int,
    MarkerID int,
    IMarkerID int
)
END

IF OBJECT_ID('tblTempFontsFamily') IS NULL
BEGIN
CREATE TABLE [dbo].[tblTempFontsFamily]
(
    FontFamilyID int identity(1,1),
    FontFaceID int,
    FaceName nvarchar(255),
    FileName nvarchar(255)
)
END

IF OBJECT_ID('tblTempFontsMarker') IS NULL
BEGIN
CREATE TABLE tblTempFontsMarker
(
    FontMarkerID int identity(1,1),
    MarkerID int,
    Filename nvarchar(255)
)
END

IF OBJECT_ID('tblTempFonts') IS NULL
BEGIN
CREATE TABLE [dbo].[tblTempFonts]
(
    FontId int,
    Description nvarchar(255),
    Size int,
    Color nvarchar(8),
    ShadowColor nvarchar(8),
    FontFaceId nvarchar(11),
    FontStyle nvarchar(10)
)
END
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTempInfoSpelling]') AND type in (N'U'))
DROP TABLE [dbo].[tblTempInfoSpelling]
GO

CREATE TABLE [dbo].[tblTempInfoSpelling](
	"InfoId"	int NOT NULL DEFAULT '0',
	"Lang_EN"	nvarchar(max)  NULL,
	"Lang_FR"	nvarchar(max)  NULL,
	"Lang_DE"	nvarchar(max)  NULL,
	"Lang_ES"	nvarchar(max)  NULL,
	"Lang_ZH"	nvarchar(max)  NULL,
	"Lang_AR"	nvarchar(max)  NULL,
	"Lang_RU"	nvarchar(max)  NULL,
	"Lang_PT"	nvarchar(max)  NULL,
	"Lang_DU"	nvarchar(max)  NULL,
	"Lang_IT"	nvarchar(max)  NULL,
	"Lang_GK"	nvarchar(max)  NULL,
	"Lang_JA"	nvarchar(max)  NULL,
	"Lang_KO"	nvarchar(max)  NULL,
	"Lang_BA"	nvarchar(max)  NULL,
	"Lang_TU"	nvarchar(max)  NULL,
	"Lang_MA"	nvarchar(max)  NULL,
	"Lang_FI"	nvarchar(max)  NULL,
	"Lang_HI"	nvarchar(max)  NULL,
	"Lang_TI"	nvarchar(max)  NULL,
	"Lang_RO"	nvarchar(max)  NULL,
	"Lang_SE"	nvarchar(max)  NULL,
	"Lang_SW"	nvarchar(max)  NULL,
	"Lang_HU"	nvarchar(max)  NULL,
	"Lang_HE"	nvarchar(max)  NULL,
	"Lang_PL"	nvarchar(max)  NULL,
	"Lang_CC"	nvarchar(max)  NULL,
	"Lang_VN"	nvarchar(max)  NULL,
	"Lang_SA"	nvarchar(max)  NULL,
	"Lang_CZ"	nvarchar(max)  NULL,
	"Lang_TO"	nvarchar(max)  NULL,
	"Lang_DA"	nvarchar(max)  NULL,
	"Lang_IC"	nvarchar(max)  NULL,
	"Lang_KK"	nvarchar(max)  NULL,
	"Lang_FA"	nvarchar(max)  NULL,
	"Lang_TK"	nvarchar(max)  NULL,
	"Lang_BN"	nvarchar(max)  NULL,
	"Lang_MN"	nvarchar(max)  NULL,
	"Lang_BO"	nvarchar(max)  NULL,
	"Lang_AZ"	nvarchar(max)  NULL,
	"Lang_EP"	nvarchar(max)  NULL,
	"Lang_LS"	nvarchar(max)  NULL,
	"Lang_NO"	nvarchar(max)  NULL,
	"Lang_LK"	nvarchar(max)  NULL		
)
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTempInfoSpelling]') AND type in (N'U'))
DROP TABLE [dbo].[tblTempInfoSpelling]
GO


IF OBJECT_ID('tblRliAeroPlaneTypes') IS NULL
BEGIN
CREATE TABLE [dbo].[tblRliAeroPlaneTypes]
(
	[AeroPlaneTypeID] int NOT NULL IDENTITY,
	[Name] nvarchar(50) NULL
);
ALTER TABLE [dbo].[tblRliAeroPlaneTypes] 
 ADD CONSTRAINT [PK_tblRliAeroPlaneTypes]
	PRIMARY KEY CLUSTERED ([AeroPlaneTypeID] ASC);
END
GO

IF OBJECT_ID('tblRliAeroPlaneTypesMap') IS NULL
BEGIN
CREATE TABLE [dbo].[tblRliAeroPlaneTypesMap]
(
	[ConfigurationID] int NULL,
	[AeroPlaneTypeID] int NULL,
	[PreviousAeroPlaneTypeID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)

ALTER TABLE [dbo].[tblRliAeroPlaneTypesMap] ADD CONSTRAINT [FK_tblRliAeroPlaneTypesMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action

ALTER TABLE [dbo].[tblRliAeroPlaneTypesMap] ADD CONSTRAINT [FK_tblRliAeroPlaneTypesMap_tblRliAeroPlaneTypes]
	FOREIGN KEY ([AeroPlaneTypeID]) REFERENCES [dbo].[tblRliAeroPlaneTypes] ([AeroPlaneTypeID]) ON DELETE No Action ON UPDATE No Action

END

IF TYPE_ID(N'[Type_PlatformData]') IS NULL
BEGIN
	IF OBJECT_ID('[dbo].[SP_SaveProductConfigurationData]', 'P') IS NOT NULL
	BEGIN
		DROP PROC [dbo].[SP_SaveProductConfigurationData]
	END
	DROP TYPE [dbo].[Type_PlatformData];
	
	CREATE TYPE [dbo].[Type_PlatformData] AS TABLE 
	(
		[ConfigurationDefinitionID] [INT] NULL,
		[PlatformName] [NVARCHAR](MAX) NULL,
		[PlatformDescription] [NVARCHAR](MAX) NULL,
		[PlatformId] [INT] NULL,
		[InstallationTypeID] [UNIQUEIDENTIFIER] NULL
	);
END
GO