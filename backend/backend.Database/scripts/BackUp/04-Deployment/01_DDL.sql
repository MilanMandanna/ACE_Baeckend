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