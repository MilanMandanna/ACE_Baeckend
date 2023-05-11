CREATE SCHEMA [cust]
    AUTHORIZATION [dbo];


GO
PRINT N'Creating Table [dbo].[tblImageType]...';


GO
CREATE TABLE [dbo].[tblImageType] (
    [ID]                       INT                         PRIMARY KEY IDENTITY, 
    [ImageType]                NVARCHAR(200), 
    [Description]              NVARCHAR(MAX)
);

GO
PRINT N'Creating Table [dbo].[tblImage]...';


GO
CREATE TABLE [dbo].[tblImage] (
    [ImageId]                  INT                         PRIMARY KEY, 
    [ImageName]                NVARCHAR(200), 
    [OriginalImagePath]        NVARCHAR(MAX), 
    [ImageTypeId]              INT,
    [IsSelected]               BIT DEFAULT 0, 
    [ImageGuid]                NVARCHAR(500)
);

GO
PRINT N'Creating Table [dbo].[tblImageMap]...';


GO
CREATE TABLE [dbo].[tblImageMap] (
    [ImageId]                  INT           NULL,
    [ConfigurationID]          INT           NULL,
    [PreviousImageId]          INT           NULL,
    [IsDeleted]                BIT 			 DEFAULT 0,
    [TimeStampModified]        TIMESTAMP     NULL,
    [LastModifiedBy]           NVARCHAR (50) NULL,
    [Action]                   NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblImageResSpec]...';


GO
CREATE TABLE [dbo].[tblImageResSpec] (
   [ConfigurationID]          int NULL, 
   [ImageId]                  INT, 
   [ResolutionId]             INT, 
   [ImagePath]                NVARCHAR(MAX)
);


GO
PRINT N'Creating Table [dbo].[tblImageres]...';


GO
CREATE TABLE [dbo].[tblImageres] (
    [ID]                       INT                         PRIMARY KEY IDENTITY, 
    [resolution]               NVARCHAR(200), 
    [IsDefault]                BIT                         DEFAULT 0, 
    [Description]              NVARCHAR(MAX)
);


GO
PRINT N'Creating Table [dbo].[tblTempCityPopulation]...';


GO
CREATE TABLE [dbo].[tblTempCityPopulation] (
    [Country]                  [NVARCHAR](250)           NULL,
    [Year]                     [NVARCHAR](50)            NULL,
    [SegmentID]                [NVARCHAR](50)            NULL,
    [Sex]                      [NVARCHAR](50)            NULL,
    [CityCode]                 [INT]                     NULL,
    [City]                     [NVARCHAR](250)           NULL,
    [CityType]                 [NVARCHAR](50)            NULL,
    [Population]               [FLOAT]                   NULL
);

GO
PRINT N'Creating Table [dbo].[tblTempWGDetailedFlightInfo]...';

CREATE TABLE [dbo].[tblTempWGDetailedFlightInfo]
(
    [Id]                    INT             NOT NULL IDENTITY (1, 1), 
    [GeoRefID]              INT             NULL, 
    [Overview]              NVARCHAR(MAX)   NULL, 
    [Features]              NVARCHAR(MAX)   NULL, 
    [Sights]                NVARCHAR(MAX)   NULL, 
    [Stats]                 NVARCHAR(MAX)   NULL, 
    [ImageFileName]         NVARCHAR(250)   NULL, 
    [Text_EN]               NVARCHAR(MAX)   NULL
)


GO
PRINT N'Creating Table [dbo].[tblTempWGCityFlightInfo]...';


CREATE TABLE [dbo].[tblTempWGCityFlightInfo](

	[Id]					INT 			NOT NULL IDENTITY(1,1), 
    [ImageFileName]			NCHAR(250) 		NULL, 
    [Description]			NVARCHAR(MAX)  	NULL, 
    [Language]				NVARCHAR(250)  	NULL, 
    [GeoRefID]				INT 			NULL
)


GO
PRINT N'Creating Table [cust].[tblFlyOverAlertMap]...';


GO
CREATE TABLE [cust].[tblFlyOverAlertMap] (
    [FlyOverAlertID]         INT           NULL,
    [ConfigurationID]        INT           NULL,
    [PreviousFlyOverAlertID] INT           NULL,
    [IsDeleted]              BIT           NULL,
    [TimeStampModified]      TIMESTAMP     NULL,
    [LastModifiedBy]         NVARCHAR (50) NULL,
    [Action]                 NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblFlyOverAlert]...';


GO
CREATE TABLE [cust].[tblFlyOverAlert] (
    [FlyOverAlertID] INT IDENTITY (1, 1) NOT NULL,
    [FlyOverAlert]   XML NULL,
    CONSTRAINT [PK_tblFlyOverAlert] PRIMARY KEY CLUSTERED ([FlyOverAlertID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblMapsMap]...';


GO
CREATE TABLE [cust].[tblMapsMap] (
    [MapID]             INT           NULL,
    [ConfigurationID]   INT           NULL,
    [PreviousMapID]     INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblMaps]...';


GO
CREATE TABLE [cust].[tblMaps] (
    [MapID]            INT IDENTITY (1, 1) NOT NULL,
    [MapItems]         XML NULL,
    [HardwareCaps]     XML NULL,
    [Borders]          XML NULL,
    [BroadCastBorders] XML NULL,
    CONSTRAINT [PK_tblMaps] PRIMARY KEY CLUSTERED ([MapID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblMakkahMap]...';


GO
CREATE TABLE [cust].[tblMakkahMap] (
    [MakkahID]          INT           NULL,
    [ConfigurationID]   INT           NULL,
    [PreviousMakkahID]  INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblMakkah]...';


GO
CREATE TABLE [cust].[tblMakkah] (
    [MakkahID] INT IDENTITY (1, 1) NOT NULL,
    [Makkah]   XML NULL,
    CONSTRAINT [PK_tblMakkah] PRIMARY KEY CLUSTERED ([MakkahID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblHtml5Map]...';


GO
CREATE TABLE [cust].[tblHtml5Map] (
    [Html5ID]           INT           NOT NULL,
    [ConfigurationID]   INT           NOT NULL,
    [PreviousHtml5ID]   INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblHtml5]...';


GO
CREATE TABLE [cust].[tblHtml5] (
    [Html5ID]   INT IDENTITY (1, 1) NOT NULL,
    [Category]  XML NULL,
    [InfoItems] XML NULL,
    CONSTRAINT [PK_tblHtml5] PRIMARY KEY CLUSTERED ([Html5ID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblHandSetMap]...';


GO
CREATE TABLE [cust].[tblHandSetMap] (
    [HandSetID]         INT           NULL,
    [ConfigurationID]   INT           NULL,
    [PreviousHandSetID] INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblHandSet]...';


GO
CREATE TABLE [cust].[tblHandSet] (
    [HandSetID] INT IDENTITY (1, 1) NOT NULL,
    [HandSet]   XML NULL,
    CONSTRAINT [PK_tblHandSet] PRIMARY KEY CLUSTERED ([HandSetID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblGlobalMap]...';


GO
CREATE TABLE [cust].[tblGlobalMap] (
    [ConfigurationID]   INT            NULL,
    [CustomID]          INT            NULL,
    [PreviousCustomID]  INT            NULL,
    [IsDeleted]         BIT            NULL,
    [TimeStampModified] TIMESTAMP      NULL,
    [LastModifiedBy]    NVARCHAR (250) NULL,
    [Action]            NVARCHAR (250) NULL
);


GO
PRINT N'Creating Table [cust].[tblGlobal]...';


GO
CREATE TABLE [cust].[tblGlobal] (
    [CustomID]        INT IDENTITY (1, 1) NOT NULL,
    [Global]          XML NULL,
    [AirportLanguage] XML NULL,
    CONSTRAINT [PK_tblCustom] PRIMARY KEY CLUSTERED ([CustomID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblResolutionMap]...';


GO
CREATE TABLE [cust].[tblResolutionMap] (
    [ResolutionID]         INT           NULL,
    [ConfigurationID]      INT           NULL,
    [PreviousResolutionID] INT           NULL,
    [IsDeleted]            BIT           NULL,
    [TimeStampModified]    TIMESTAMP     NULL,
    [LastModifiedBy]       NVARCHAR (50) NULL,
    [Action]               NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblResolution]...';


GO
CREATE TABLE [cust].[tblResolution] (
    [ResolutionID] INT IDENTITY (1, 1) NOT NULL,
    [Resolution]   XML NULL,
    CONSTRAINT [PK_tblResolution] PRIMARY KEY CLUSTERED ([ResolutionID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblPersonalityListMap]...';


GO
CREATE TABLE [cust].[tblPersonalityListMap] (
    [ConfigurationID]           INT           NULL,
    [PersonalityListID]         INT           NULL,
    [PreviousPersonalityListID] INT           NULL,
    [isDeleted]                 BIT           NULL,
    [TimeStampModified]         TIMESTAMP     NULL,
    [LastModifiedBy]            NVARCHAR (50) NULL,
    [Action]                    NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblPersonalityList]...';


GO
CREATE TABLE [cust].[tblPersonalityList] (
    [PersonalityListID] INT IDENTITY (1, 1) NOT NULL,
    [Personality]       XML NULL,
    CONSTRAINT [PK_tblPersonalityList] PRIMARY KEY CLUSTERED ([PersonalityListID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblNewsMap]...';


GO
CREATE TABLE [cust].[tblNewsMap] (
    [ConfigurationID]   INT           NULL,
    [NewsID]            INT           NULL,
    [IsDeleted]         BIT           NULL,
    [PreviousNewsID]    INT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblNews]...';


GO
CREATE TABLE [cust].[tblNews] (
    [NewsID] INT IDENTITY (1, 1) NOT NULL,
    [News]   XML NULL,
    CONSTRAINT [PK_tblNews] PRIMARY KEY CLUSTERED ([NewsID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblModeDefsMap]...';


GO
CREATE TABLE [cust].[tblModeDefsMap] (
    [ModeDefID]         INT           NULL,
    [ConfigurationID]   INT           NULL,
    [PreviousModeDefID] INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblModeDefs]...';


GO
CREATE TABLE [cust].[tblModeDefs] (
    [ModeDefID] INT IDENTITY (1, 1) NOT NULL,
    [ModeDefs]  XML NULL,
    CONSTRAINT [PK_tblModeDefs] PRIMARY KEY CLUSTERED ([ModeDefID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblMiqatMap]...';


GO
CREATE TABLE [cust].[tblMiqatMap] (
    [ConfigurationID]   INT           NULL,
    [MiqatID]           INT           NULL,
    [IsDeleted]         BIT           NULL,
    [PreviousMiqatID]   INT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblMiqat]...';


GO
CREATE TABLE [cust].[tblMiqat] (
    [MiqatID] INT IDENTITY (1, 1) NOT NULL,
    [Miqat]   XML NULL,
    CONSTRAINT [PK_tblMiqat] PRIMARY KEY CLUSTERED ([MiqatID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblMenuMap]...';


GO
CREATE TABLE [cust].[tblMenuMap] (
    [ConfigurationID]   INT           NULL,
    [MenuID]            INT           NULL,
    [PreviousMenuID]    INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblMenu]...';


GO
CREATE TABLE [cust].[tblMenu] (
    [MenuID]      INT IDENTITY (1, 1) NOT NULL,
    [Perspective] XML NULL,
    [Layers]      XML NULL,
    [IsHTML5]     BIT NULL,
    CONSTRAINT [PK_tblMenu] PRIMARY KEY CLUSTERED ([MenuID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblTimeZoneGlobePlaceNamesMap]...';


GO
CREATE TABLE [cust].[tblTimeZoneGlobePlaceNamesMap] (
    [PlaceNameID]         INT           NOT NULL,
    [ConfigurationID]     INT           NULL,
    [PreviousPlaceNameID] INT           NULL,
    [IsDeleted]           BIT           NULL,
    [TimeStampModified]   TIMESTAMP     NULL,
    [LastModifiedBy]      NVARCHAR (50) NULL,
    [Action]              NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblTimeZoneGlobePlaceNames]...';


GO
CREATE TABLE [cust].[tblTimeZoneGlobePlaceNames] (
    [PlaceNameID] INT IDENTITY (1, 1) NOT NULL,
    [PlaceNames]  XML NULL,
    CONSTRAINT [PK_tblTimeZoneGlobePlaceNames] PRIMARY KEY CLUSTERED ([PlaceNameID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblTickerMap]...';


GO
CREATE TABLE [cust].[tblTickerMap] (
    [TickerID]          INT           NULL,
    [ConfigurationID]   INT           NULL,
    [PreviousTickerID]  INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblTicker]...';


GO
CREATE TABLE [cust].[tblTicker] (
    [TickerID] INT IDENTITY (1, 1) NOT NULL,
    [Ticker]   XML NULL,
    CONSTRAINT [PK_tblTicker] PRIMARY KEY CLUSTERED ([TickerID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblScriptDefsMap]...';


GO
CREATE TABLE [cust].[tblScriptDefsMap] (
    [ScriptDefID]         INT           NULL,
    [ConfigurationID]     INT           NULL,
    [PreviousScriptDefID] INT           NULL,
    [IsDeleted]           BIT           NULL,
    [TimeStampModified]   TIMESTAMP     NULL,
    [LastModifiedBy]      NVARCHAR (50) NULL,
    [Action]              NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblScriptDefs]...';


GO
CREATE TABLE [cust].[tblScriptDefs] (
    [ScriptDefID] INT IDENTITY (1, 1) NOT NULL,
    [ScriptDefs]  XML NULL,
    CONSTRAINT [PK_tblScriptDefs] PRIMARY KEY CLUSTERED ([ScriptDefID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblRLIMap]...';


GO
CREATE TABLE [cust].[tblRLIMap] (
    [RLIID]             INT           NULL,
    [ConfigurationID]   INT           NULL,
    [PreviousRLIID]     INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblRli]...';


GO
CREATE TABLE [cust].[tblRli] (
    [RLIID] INT IDENTITY (1, 1) NOT NULL,
    [Rli]   XML NULL,
    CONSTRAINT [PK_tblRli] PRIMARY KEY CLUSTERED ([RLIID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblWebMainMap]...';


GO
CREATE TABLE [cust].[tblWebMainMap] (
    [ConfigurationID]   INT           NULL,
    [WebMainID]         INT           NULL,
    [PreviousWebMainID] INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblWebMain]...';


GO
CREATE TABLE [cust].[tblWebMain] (
    [WebMainID]    INT IDENTITY (1, 1) NOT NULL,
    [WebMainItems] XML NULL,
    [InfoItems]    XML NULL,
    CONSTRAINT [PK_tblInfoItems] PRIMARY KEY CLUSTERED ([WebMainID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblTzPoisMap]...';


GO
CREATE TABLE [cust].[tblTzPoisMap]
(
	[TzPoisID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousTzPoisID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
);


GO
PRINT N'Creating Table [cust].[tblTzPois]...';


GO
CREATE TABLE [cust].[tblTzPois] (
    [TzPoisID] INT IDENTITY (1, 1) NOT NULL,
    [TZPois]   XML NULL,
    CONSTRAINT [PK_tblTzPois] PRIMARY KEY CLUSTERED ([TzPoisID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblTriggerMap]...';


GO
CREATE TABLE [cust].[tblTriggerMap] (
    [TriggerID]         INT           NULL,
    [ConfigurationID]   INT           NULL,
    [PreviousTriggerID] INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblTrigger]...';


GO
CREATE TABLE [cust].[tblTrigger] (
    [TriggerID]   INT IDENTITY (1, 1) NOT NULL,
    [TriggerDefs] XML NULL,
    CONSTRAINT [PK_tblTrigger] PRIMARY KEY CLUSTERED ([TriggerID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblWorldTimeZonePlaceNamesMap]...';


GO
CREATE TABLE [cust].[tblWorldTimeZonePlaceNamesMap] (
    [PlaceNameID]         INT           NOT NULL,
    [ConfigurationID]     INT           NULL,
    [PreviousPlaceNameID] INT           NULL,
    [IsDeleted]           BIT           NULL,
    [TimeStampModified]   TIMESTAMP     NULL,
    [LastModifiedBy]      NVARCHAR (50) NULL,
    [Action]              NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblWorldTimeZonePlaceNames]...';


GO
CREATE TABLE [cust].[tblWorldTimeZonePlaceNames] (
    [PlaceNameID] INT IDENTITY (1, 1) NOT NULL,
    [PlaceNames]  XML NULL,
    CONSTRAINT [PK_tblWorldTimeZonePlaceNames] PRIMARY KEY CLUSTERED ([PlaceNameID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblWorldMapPlaceNamesMap]...';


GO
CREATE TABLE [cust].[tblWorldMapPlaceNamesMap] (
    [PlaceNameID]         INT           NOT NULL,
    [ConfigurationID]     INT           NULL,
    [PreviousPlaceNameID] INT           NULL,
    [IsDeleted]           BIT           NULL,
    [TimeStampModified]   TIMESTAMP     NULL,
    [LastModifiedBy]      NVARCHAR (50) NULL,
    [Action]              NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblWorldMapPlaceNames]...';


GO
CREATE TABLE [cust].[tblWorldMapPlaceNames] (
    [PlaceNameID] INT IDENTITY (1, 1) NOT NULL,
    [PlaceNames]  XML NULL,
    CONSTRAINT [PK_tblWorldMapPlaceNames] PRIMARY KEY CLUSTERED ([PlaceNameID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblWorldMapCitiesMap]...';


GO
CREATE TABLE [cust].[tblWorldMapCitiesMap] (
    [WorldMapCityID]         INT           NOT NULL,
    [ConfigurationID]        INT           NOT NULL,
    [PreviousWorldMapCityID] INT           NULL,
    [IsDeleted]              BIT           NULL,
    [TimeStampModified]      TIMESTAMP     NULL,
    [LastModifiedBy]         NVARCHAR (50) NULL,
    [Action]                 NVARCHAR (50) NULL,
    CONSTRAINT [PK_tblWorldMapCitiesMap] PRIMARY KEY CLUSTERED ([WorldMapCityID] ASC, [ConfigurationID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblWorldMapCities]...';


GO
CREATE TABLE [cust].[tblWorldMapCities] (
    [WorldMapCityID] INT IDENTITY (1, 1) NOT NULL,
    [WorldMapCities] XML NULL,
    CONSTRAINT [PK_WorldClockCities_copy] PRIMARY KEY CLUSTERED ([WorldMapCityID] ASC)
);


GO
PRINT N'Creating Table [cust].[tblWorldClockCitiesMap]...';


GO
CREATE TABLE [cust].[tblWorldClockCitiesMap] (
    [WorldClockCityID]         INT           NULL,
    [ConfigurationID]          INT           NULL,
    [PreviousWorldClockCityID] INT           NULL,
    [IsDeleted]                BIT           NULL,
    [TimeStampModified]        TIMESTAMP     NULL,
    [LastModifiedBy]           NVARCHAR (50) NULL,
    [Action]                   NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [cust].[tblWorldClockCities]...';


GO
CREATE TABLE [cust].[tblWorldClockCities] (
    [WorldClockCityID] INT NOT NULL,
    [WorldClockCities] XML NULL,
    CONSTRAINT [PK_WorldClockCities] PRIMARY KEY CLUSTERED ([WorldClockCityID] ASC)
);

CREATE TABLE [dbo].[tblConfigTables](
	[tblName] [nvarchar](128) NULL
)
GO

GO
PRINT N'Creating Table [cust].[tblConfigVersionMap]...';


GO
CREATE TABLE [cust].[tblConfigVersionMap] (
    [ConfigVersionID]         INT           NULL,
    [ConfigurationID]         INT           NULL,
    [PreviousConfigVersionID] INT           NULL,
    [isDeleted]               BIT           NULL,
    [TimeStampModified]       TIMESTAMP     NULL,
    [LastModifiedBy]          NVARCHAR (50) NULL,
    [Action]                  NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [cust].[tblConfigVersionMap].[IXFK_tblConfigVersionMap_tblConfigurations]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigVersionMap_tblConfigurations]
    ON [cust].[tblConfigVersionMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [cust].[tblConfigVersionMap].[IXFK_tblConfigVersionMap_tblConfigVersion]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigVersionMap_tblConfigVersion]
    ON [cust].[tblConfigVersionMap]([ConfigVersionID] ASC);


GO
PRINT N'Creating Table [cust].[tblConfigVersion]...';


GO
CREATE TABLE [cust].[tblConfigVersion] (
    [ConfigVersionID] INT IDENTITY (1, 1) NOT NULL,
    [Version]         XML NULL,
    CONSTRAINT [PK_tblConfigVersion] PRIMARY KEY CLUSTERED ([ConfigVersionID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblAircraftConfigurationMapping]...';


GO
CREATE TABLE [dbo].[tblAircraftConfigurationMapping] (
    [ConfigurationDefinitionID] INT              NULL,
    [MappingIndex]              INT              NULL,
    [AircraftID]                UNIQUEIDENTIFIER NULL
);


GO
PRINT N'Creating Table [dbo].[tblAircraftDestinations]...';


GO
CREATE TABLE [dbo].[tblAircraftDestinations] (
    [Aircraft_ID]    INT NOT NULL,
    [Destination_ID] INT NOT NULL
);


GO
PRINT N'Creating Table [dbo].[tblAircraftDocumentFolders]...';


GO
CREATE TABLE [dbo].[tblAircraftDocumentFolders] (
    [Aircraft_ID]       INT NOT NULL,
    [DocumentFolder_ID] INT NOT NULL
);


GO
PRINT N'Creating Table [dbo].[tblAirportInfo]...';


GO
CREATE TABLE [dbo].[tblAirportInfo] (
    [AirportInfoID] INT             IDENTITY (1, 1) NOT NULL,
    [FourLetID]     NVARCHAR (4)    NULL,
    [ThreeLetID]    NVARCHAR (3)    NULL,
    [Lat]           DECIMAL (12, 9) NULL,
    [Lon]           DECIMAL (12, 9) NULL,
    [GeoRefID]      INT             NULL,
    [CityName]      NVARCHAR (255)  NULL,
    [DataSourceID]  INT             NULL,
    [ModifyDate]    TIMESTAMP       NOT NULL,
    CONSTRAINT [PK_tblAirportInfo] PRIMARY KEY CLUSTERED ([AirportInfoID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblAirportInfoMap]...';


GO
CREATE TABLE [dbo].[tblAirportInfoMap] (
    [ConfigurationID]       INT           NULL,
    [AirportInfoID]         INT           NULL,
    [PreviousAirportInfoID] INT           NULL,
    [IsDeleted]             BIT           NULL,
    [TimeStampModified]     TIMESTAMP     NOT NULL,
    [LastModifiedBy]        NVARCHAR (50) NULL,
    [Action]                NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblAirshowSubscriptionAssignment]...';


GO
CREATE TABLE [dbo].[tblAirshowSubscriptionAssignment] (
    [ID]                        UNIQUEIDENTIFIER NOT NULL,
    [ConfigurationDefinitionID] INT              NULL,
    [SubscriptionID]            UNIQUEIDENTIFIER NULL,
    [DateNextSubscriptionCheck] DATETIME         NULL,
    [IsActive]                  BIT              NULL,
    CONSTRAINT [PK_tblAirshowSubscriptionAssignment] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblAppearance]...';


GO
CREATE TABLE [dbo].[tblAppearance] (
    [AppearanceID]        INT IDENTITY (1, 1) NOT NULL,
    [GeoRefID]            INT NULL,
    [Resolution]          decimal(18, 10) NULL, -- Map resolution expressed in arcseconds.  A value of 0 indicates N/A.
    [ResolutionMpp]       INT NULL,
    [Exclude]             BIT NULL,
    [SphereMapExclude]    BIT NULL,
    [CustomChangeBitMask] INT NOT NULL,
    CONSTRAINT [PK_tblAppearance] PRIMARY KEY CLUSTERED ([AppearanceID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblAppearanceMap]...';


GO
CREATE TABLE [dbo].[tblAppearanceMap] (
    [ConfigurationID]      INT           NULL,
    [AppearanceID]         INT           NULL,
    [PreviousAppearanceID] INT           NULL,
    [IsDeleted]            BIT           NULL,
    [TimeStampModified]    TIMESTAMP     NULL,
    [LastModifiedBy]       NVARCHAR (50) NULL,
    [Action]               NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblAppearanceMap].[IXFK_tblAppearanceMap_tblAppearance]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblAppearanceMap_tblAppearance]
    ON [dbo].[tblAppearanceMap]([AppearanceID] ASC);



GO
PRINT N'Creating Table [dbo].[tblArea]...';


GO
CREATE TABLE [dbo].[tblArea] (
    [AreaID]           INT       IDENTITY (1, 1) NOT NULL,
    [GeoRefID]         INT       NULL,
    [Area]             INT       NULL,
    [LastModifiedDate] TIMESTAMP NOT NULL,
    [DataSourceID]     INT       NULL,
    CONSTRAINT [PK_tblArea] PRIMARY KEY CLUSTERED ([AreaID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblAreaMap]...';


GO
CREATE TABLE [dbo].[tblAreaMap] (
    [ConfigurationID]   INT           NULL,
    [AreaID]            INT           NULL,
    [PreviousAreaID]    INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblAreaMap].[IXFK_tblAreaMap_tblArea]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblAreaMap_tblArea]
    ON [dbo].[tblAreaMap]([AreaID] ASC);


GO
PRINT N'Creating Index [dbo].[tblAreaMap].[IXFK_tblAreaMap_tblConfigurations]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblAreaMap_tblConfigurations]
    ON [dbo].[tblAreaMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Table [dbo].[tblASXiInset]...';


GO
CREATE TABLE [dbo].[tblASXiInset] (
    [ASXiInsetID]    INT            IDENTITY (1, 1) NOT NULL,
    [InsetName]      NVARCHAR (50)  NULL,
    [Zoom]           FLOAT (53)     NULL,
    [Path]           NVARCHAR (MAX) NULL,
    [MapPackageType] NVARCHAR (50)  NULL,
    [RowStart]       INT            NULL,
    [RowEnd]         INT            NULL,
    [ColStart]       INT            NULL,
    [ColEnd]         INT            NULL,
    [LatStart]       FLOAT (53)     NULL,
    [LatEnd]         FLOAT (53)     NULL,
    [LongStart]      FLOAT (53)     NULL,
    [LongEnd]        FLOAT (53)     NULL,
    [IsHf]           BIT            NULL,
    [PartNumber]     INT            NULL,
    [Cdata]          VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_tblASXiInset] PRIMARY KEY CLUSTERED ([ASXiInsetID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblASXiInsetMap]...';


GO
CREATE TABLE [dbo].[tblASXiInsetMap] (
    [ConfigurationID]     INT           NULL,
    [ASXiInsetID]         INT           NULL,
    [PreviousASXiInsetID] INT           NULL,
    [IsDeleted]           BIT           NULL,
    [TimeStampModified]   TIMESTAMP     NOT NULL,
    [LastModifiedBy]      NVARCHAR (50) NULL,
    [Action]              NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblAsxiProfile]...';


GO
CREATE TABLE [dbo].[tblAsxiProfile] (
    [AsxiProfileID] INT IDENTITY (1, 1) NOT NULL,
    [AsxiProfile]   XML NULL,
    CONSTRAINT [PK_tblAsxiProfile] PRIMARY KEY CLUSTERED ([AsxiProfileID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblAsxiProfileMap]...';


GO
CREATE TABLE [dbo].[tblAsxiProfileMap] (
    [ConfigurationID]       INT           NULL,
    [AsxiProfileID]         INT           NULL,
    [PreviousAsxiProfileID] INT           NULL,
    [IsDeleted]             BIT           NULL,
    [TimeStampModified]     TIMESTAMP     NOT NULL,
    [LastModifiedBy]        NVARCHAR (50) NULL,
    [Action]                NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblAsxiWorldGuideText]...';


GO
CREATE TABLE [dbo].[tblAsxiWorldGuideText] (
    [AsxiWorldGuideTextID] INT       IDENTITY (1, 1) NOT NULL,
    [TextID]               INT       NULL,
    [LanguageID]           INT       NULL,
    [DataSourceID]         INT       NULL,
    [LastModifiedDate]     TIMESTAMP NULL,
    [SourceDate]           DATE      NULL,
    [DoSpellCheck]         BIT       NULL,
    CONSTRAINT [PK_tblAsxiWorldGuideText] PRIMARY KEY CLUSTERED ([AsxiWorldGuideTextID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblAsxiWorldGuideTextMap]...';


GO
CREATE TABLE [dbo].[tblAsxiWorldGuideTextMap] (
    [ConfigurationID]              INT           NULL,
    [AsxiWorldGuideTextID]         INT           NULL,
    [PreviousAsxiWorldGuideTextID] INT           NULL,
    [IsDeleted]                    BIT           NULL,
    [TimeStampModified]            TIMESTAMP     NULL,
    [LastModifiedBy]               NVARCHAR (50) NULL,
    [Action]                       NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblAsxiWorldGuideTextMap].[IXFK_tblAsxiWorldGuidTextMap_tblAsxiWorldGuideText]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblAsxiWorldGuidTextMap_tblAsxiWorldGuideText]
    ON [dbo].[tblAsxiWorldGuideTextMap]([AsxiWorldGuideTextID] ASC);


GO
PRINT N'Creating Index [dbo].[tblAsxiWorldGuideTextMap].[IXFK_tblAsxiWorldGuidTextMap_tblConfigurationReferences]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblAsxiWorldGuidTextMap_tblConfigurationReferences]
    ON [dbo].[tblAsxiWorldGuideTextMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Table [dbo].[tblCategoryType]...';


GO
CREATE TABLE [dbo].[tblCategoryType] (
    [CategoryTypeID]                   INT            IDENTITY (1, 1) NOT NULL,
    [GeoRefCategoryTypeID]             INT            NULL,
    [GeoRefCategoryTypeID_ASXIAndroid] INT            NULL,
    [Description]                      NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblCategoryType] PRIMARY KEY CLUSTERED ([CategoryTypeID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblCityPopulation]...';


GO
CREATE TABLE [dbo].[tblCityPopulation] (
    [CityPopulationID]  INT       IDENTITY (1, 1) NOT NULL,
    [GeoRefID]          INT       NULL,
    [UnCodeID]          INT       NULL,
    [Population]        INT       NULL,
    [TimeStampModified] TIMESTAMP NOT NULL,
    [SourceDate]        DATETIME  NULL,
    CONSTRAINT [PK_tblCityPopulation] PRIMARY KEY CLUSTERED ([CityPopulationID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblCityPopulationMap]...';


GO
CREATE TABLE [dbo].[tblCityPopulationMap] (
    [ConfigurationID]          INT           NULL,
    [CityPopulationID]         INT           NULL,
    [PreviousCityPopulationID] INT           NULL,
    [IsDeleted]                BIT           NULL,
    [TimeStampModified]        TIMESTAMP     NULL,
    [LastModifiedBy]           NVARCHAR (50) NULL,
    [Action]                   NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblCityPopulationMap].[IXFK_tblCityPopulationMap_tblCityPopulation]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblCityPopulationMap_tblCityPopulation]
    ON [dbo].[tblCityPopulationMap]([CityPopulationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblCityPopulationMap].[IXFK_tblCityPopulationMap_tblConfigurations]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblCityPopulationMap_tblConfigurations]
    ON [dbo].[tblCityPopulationMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Table [dbo].[tblConfigurationComponents]...';


GO
CREATE TABLE [dbo].[tblConfigurationComponents] (
    [ConfigurationComponentID]     INT            NOT NULL,
    [Path]                         NVARCHAR (500) NULL,
    [ConfigurationComponentTypeID] INT            NULL,
    [Name]                         NVARCHAR (50)  NULL,
    CONSTRAINT [PK_tblConfigurationComponents] PRIMARY KEY CLUSTERED ([ConfigurationComponentID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblConfigurationComponentsMap]...';


GO
CREATE TABLE [dbo].[tblConfigurationComponentsMap] (
    [ConfigurationID]                  INT           NULL,
    [ConfigurationComponentID]         INT           NULL,
    [PreviousConfigurationComponentID] INT           NULL,
    [IsDeleted]                        BIT           NULL,
    [TimeStampModified]                TIMESTAMP     NULL,
    [LastModifiedBy]                   NVARCHAR (50) NULL,
    [Action]                           NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblConfigurationComponentType]...';


GO
CREATE TABLE [dbo].[tblConfigurationComponentType] (
    [ConfigurationComponentTypeID] INT           NOT NULL,
    [Name]                         NVARCHAR (50) NULL,
    [Description]                  NVARCHAR (50) NULL,
    CONSTRAINT [PK_tblConfigurationComponentType] PRIMARY KEY CLUSTERED ([ConfigurationComponentTypeID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblConfigurationDefinitions]...';


GO
CREATE TABLE [dbo].[tblConfigurationDefinitions] (
    [ConfigurationDefinitionID]       INT NOT NULL,
    [ConfigurationDefinitionParentID] INT NULL,
    [ConfigurationTypeID]             INT NULL,
    [OutputTypeID]                    INT NULL,
    [Active]                          BIT NULL,
    [AutoLock]                        INT NULL,
    [AutoDeploy]                      INT NULL,
    [AutoMerge]                       INT NULL,
    [FeatureSetID]                    INT NULL,
    CONSTRAINT [PK_tblConfigurationDefinitions] PRIMARY KEY CLUSTERED ([ConfigurationDefinitionID] ASC)
);


GO
PRINT N'Creating Index [dbo].[tblConfigurationDefinitions].[IXFK_tblConfigurationDefinitions_tblFeatureSet]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigurationDefinitions_tblFeatureSet]
    ON [dbo].[tblConfigurationDefinitions]([FeatureSetID] ASC);


GO
PRINT N'Creating Table [dbo].[tblConfigurations]...';


GO
CREATE TABLE [dbo].[tblConfigurations] (
    [ConfigurationID]           INT                 NOT NULL,
    [ConfigurationDefinitionID] INT                 NULL,
    [Version]                   INT                 NULL,
    [Locked]                    BIT                 NULL,
    [Description]               NVARCHAR (255)      NULL,
    [TimestampModified]         TIMESTAMP           NOT NULL,
    [LockComment]               NVARCHAR (MAX)      NULL,
    [LockDate]          datetimeoffset(7)   NULL,
    CONSTRAINT [PK_tblConfigurationReferences] PRIMARY KEY CLUSTERED ([ConfigurationID] ASC)
);


GO
PRINT N'Creating Index [dbo].[tblConfigurations].[IXFK_tblConfigurationReferences_tblConfigurationReferences]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigurationReferences_tblConfigurationReferences]
    ON [dbo].[tblConfigurations]([ConfigurationDefinitionID] ASC);


GO
PRINT N'Creating Index [dbo].[tblConfigurations].[IXFK_tblConfigurationReferences_tblProducts]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigurationReferences_tblProducts]
    ON [dbo].[tblConfigurations]([Version] ASC);


GO
PRINT N'Creating Table [dbo].[tblConfigurationTypes]...';


GO
CREATE TABLE [dbo].[tblConfigurationTypes] (
    [ConfigurationTypeID] INT           NOT NULL,
    [Name]                NVARCHAR (50) NULL,
    [UsesTimezone]        TINYINT       NULL,
    [UsesPlacenames]      BIT           NULL,
    CONSTRAINT [PK_tblConfigurationTypes] PRIMARY KEY CLUSTERED ([ConfigurationTypeID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblCountry]...';


GO
CREATE TABLE [dbo].[tblCountry] (
    [CountryID]   INT           IDENTITY (1, 1) NOT NULL,
    [Description] NVARCHAR (50) NULL,
    [CountryCode] NVARCHAR (2)  NULL,
    [ISO3166Code] NVARCHAR (2)  NULL,
    [RegionID]    INT           NULL,
    CONSTRAINT [PK_tblCountry] PRIMARY KEY CLUSTERED ([CountryID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblCountryMap]...';


GO
CREATE TABLE [dbo].[tblCountryMap] (
    [ConfigurationID]   INT           NULL,
    [CountryID]         INT           NULL,
    [PreviousCountryID] INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblCountryMap].[IXFK_tblCountryMap_tblConfigurations]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblCountryMap_tblConfigurations]
    ON [dbo].[tblCountryMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblCountryMap].[IXFK_tblCountryMap_tblCountry]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblCountryMap_tblCountry]
    ON [dbo].[tblCountryMap]([CountryID] ASC);


GO
PRINT N'Creating Table [dbo].[tblCountrySpelling]...';


GO
CREATE TABLE [dbo].[tblCountrySpelling] (
    [CountrySpellingID] INT            IDENTITY (1, 1) NOT NULL,
    [CountryID]         INT            NULL,
    [CountryName]       NVARCHAR (255) NULL,
    [LanguageID]        INT            NULL,
    [doSpellCheck]      BIT            NULL,
    CONSTRAINT [PK_tblCountrySpelling] PRIMARY KEY CLUSTERED ([CountrySpellingID] ASC)
);


GO
PRINT N'Creating Index [dbo].[tblCountrySpelling].[IXFK_tblCountrySpelling_tblCountry]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblCountrySpelling_tblCountry]
    ON [dbo].[tblCountrySpelling]([CountryID] ASC);


GO
PRINT N'Creating Table [dbo].[tblCountrySpellingMap]...';


GO
CREATE TABLE [dbo].[tblCountrySpellingMap] (
    [ConfigurationID]           INT           NULL,
    [CountrySpellingID]         INT           NULL,
    [PreviousCountrySpellingID] INT           NULL,
    [IsDeleted]                 BIT           NULL,
    [TimeStampModified]         TIMESTAMP     NULL,
    [LastModifiedBy]            NVARCHAR (50) NULL,
    [Action]                    NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblCoverageSegment]...';


GO
CREATE TABLE [dbo].[tblCoverageSegment] (
    [ID]                  INT             IDENTITY (1, 1) NOT NULL,
    [GeoRefID]            INT             NULL,
    [SegmentID]           INT             NULL,
    [Lat1]                DECIMAL (12, 9) NULL,
    [Lon1]                DECIMAL (12, 9) NULL,
    [Lat2]                DECIMAL (12, 9) NULL,
    [Lon2]                DECIMAL (12, 9) NULL,
    [DataSourceID]        INT             NULL,
    [LastModifiedTime]    TIMESTAMP       NOT NULL,
    [SourceDate]          DATE            NULL,
    [CustomChangeBitMask] INT             NOT NULL,
    CONSTRAINT [PK_tblCoverageSegment] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblCoverageSegmentMap]...';


GO
CREATE TABLE [dbo].[tblCoverageSegmentMap] (
    [ConfigurationID]           INT           NULL,
    [CoverageSegmentID]         INT           NULL,
    [PreviousCoverageSegmentID] INT           NULL,
    [IsDeleted]                 BIT           NULL,
    [TimeStampModified]         TIMESTAMP     NULL,
    [LastModifiedBy]            NVARCHAR (50) NULL,
    [Action]                    NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblCoverageSegmentMap].[IXFK_tblCoverageSegmentMap_tblConfigurations]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblCoverageSegmentMap_tblConfigurations]
    ON [dbo].[tblCoverageSegmentMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblCoverageSegmentMap].[IXFK_tblCoverageSegmentMap_tblCoverageSegment]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblCoverageSegmentMap_tblCoverageSegment]
    ON [dbo].[tblCoverageSegmentMap]([CoverageSegmentID] ASC);


GO
PRINT N'Creating Table [dbo].[tblElevation]...';


GO
CREATE TABLE [dbo].[tblElevation] (
    [ID]           INT IDENTITY (1, 1) NOT NULL,
    [GeoRefID]     INT NULL,
    [Elevation]    INT NULL,
    [DatasourceID] INT NULL,
    CONSTRAINT [PK_tblElevation] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblElevationMap]...';


GO
CREATE TABLE [dbo].[tblElevationMap] (
    [ConfigurationID]     INT           NULL,
    [ElevationID]         INT           NULL,
    [PreviousElevationID] INT           NULL,
    [IsDeleted]           BIT           NULL,
    [TimeStampModified]   TIMESTAMP     NOT NULL,
    [LastModifiedBy]      NVARCHAR (50) NULL,
    [Action]              NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblFeatureSet]...';


GO
CREATE TABLE [dbo].[tblFeatureSet]
(
	[FeatureSetID] int NOT NULL,
	[Name] nvarchar(255) NULL,
	[value] text NULL
);


GO
PRINT N'Creating Table [dbo].[tblFleetConfigurationMapping]...';


GO
CREATE TABLE [dbo].[tblFleetConfigurationMapping] (
    [FleetID]                   INT NULL,
    [ConfigurationDefinitionID] INT NULL
);


GO
PRINT N'Creating Table [dbo].[tblFleets]...';


GO
CREATE TABLE [dbo].[tblFleets] (
    [FleetID]     INT            NOT NULL,
    [Name]        NVARCHAR (255) NULL,
    [Description] NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblFleets] PRIMARY KEY CLUSTERED ([FleetID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFont]...';


GO
CREATE TABLE [dbo].[tblFont] (
    [FontID]      INT            NOT NULL,
    [Description] NVARCHAR (255) NULL,
    [Size]        INT            NULL,
    [Color]       NVARCHAR (8)   NULL,
    [ShadowColor] NVARCHAR (8)   NULL,
    [FontFaceId]  NVARCHAR (11)  NULL,
    [FontStyle]   NVARCHAR (10)  NULL,
    CONSTRAINT [PK_tblFont] PRIMARY KEY CLUSTERED ([FontID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFontCategory]...';


GO
CREATE TABLE [dbo].[tblFontCategory] (
    [FontCategoryID]    INT NOT NULL,
    [GeoRefIdCatTypeID] INT NULL,
    [LanguageID]        INT NULL,
    [FontID]            INT NULL,
    [MarkerID]          INT NULL,
    [IMarkerID]         INT NULL,
    CONSTRAINT [PK_tblFontCategory] PRIMARY KEY CLUSTERED ([FontCategoryID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFontCategoryMap]...';


GO
CREATE TABLE [dbo].[tblFontCategoryMap] (
    [ConfigurationID]        INT           NULL,
    [FontCategoryID]         INT           NULL,
    [PreviousFontCategoryID] INT           NULL,
    [IsDeleted]              BIT           NULL,
    [TimeStampModified]      TIMESTAMP     NOT NULL,
    [LastModifiedBy]         NVARCHAR (50) NULL,
    [Action]                 NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblFontDefaultCategory]...';


GO
CREATE TABLE [dbo].[tblFontDefaultCategory] (
    [FontDefaultCategoryID] INT NOT NULL,
    [GeoRefIdCatTypeID]     INT NOT NULL,
    [Resolution]            INT NOT NULL,
    [FontID]                INT NULL,
    [SphereFontID]          INT NULL,
    [MarkerID]              INT NULL,
    [AtlasMarkerID]         INT NULL,
    [SphereMarkerID]        INT NULL,
    CONSTRAINT [PK_tblFontDefaultCategory] PRIMARY KEY CLUSTERED ([FontDefaultCategoryID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFontDefaultCategoryMap]...';


GO
CREATE TABLE [dbo].[tblFontDefaultCategoryMap] (
    [ConfigurationID]               INT           NULL,
    [FontDefaultCategoryID]         INT           NULL,
    [PreviousFontDefaultCategoryID] INT           NULL,
    [IsDeleted]                     BIT           NULL,
    [TimeStampModified]             TIMESTAMP     NOT NULL,
    [LastModifiedBy]                NVARCHAR (50) NULL,
    [Action]                        NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblFontFamily]...';


GO
CREATE TABLE [dbo].[tblFontFamily] (
    [FontFamilyID] INT            NOT NULL,
    [FontFaceID]   INT            NULL,
    [FaceName]     NVARCHAR (255) NULL,
    [FileName]     NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblFontFamily] PRIMARY KEY CLUSTERED ([FontFamilyID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFontFamilyMap]...';


GO
CREATE TABLE [dbo].[tblFontFamilyMap] (
    [ConfigurationID]      INT           NULL,
    [FontFamilyID]         INT           NULL,
    [PreviousFontFamilyID] INT           NULL,
    [IsDeleted]            BIT           NULL,
    [TimeStampModified]    TIMESTAMP     NULL,
    [LastModifiedBy]       NVARCHAR (50) NULL,
    [Action]               NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblFontFiles]...';


GO
CREATE TABLE [dbo].[tblFontFiles] (
    [FontFileID]  INT            IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (255) NULL,
    [Description] NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblFontFiles] PRIMARY KEY CLUSTERED ([FontFileID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFontFileSelection]...';


GO
CREATE TABLE [dbo].[tblFontFileSelection] (
    [FontFileSelectionID] INT IDENTITY (1, 1) NOT NULL,
    [FontFileID]          INT NULL,
    CONSTRAINT [PK_tblFontFileSelection] PRIMARY KEY CLUSTERED ([FontFileSelectionID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFontFileSelectionMap]...';


GO
CREATE TABLE [dbo].[tblFontFileSelectionMap] (
    [ConfigurationID]             INT           NULL,
    [FontFileSelectionID]         INT           NULL,
    [PreviousFontFileSelectionID] INT           NULL,
    [IsDeleted]                   BIT           NULL,
    [TimeStampModified]           TIMESTAMP     NULL,
    [LastModifiedBy]              NVARCHAR (50) NULL,
    [Action]                      NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblFontFileSelectionMap].[IXFK_tblFontFileSelectionMap_tblConfigurations]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblFontFileSelectionMap_tblConfigurations]
    ON [dbo].[tblFontFileSelectionMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblFontFileSelectionMap].[IXFK_tblFontFileSelectionMap_tblFontFileSelection]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblFontFileSelectionMap_tblFontFileSelection]
    ON [dbo].[tblFontFileSelectionMap]([FontFileSelectionID] ASC);


GO
PRINT N'Creating Table [dbo].[tblFontFilesMap]...';


GO
CREATE TABLE [dbo].[tblFontFilesMap] (
    [ConfigurationID]    INT            NULL,
    [FontFileID]         INT            NULL,
    [PreviousFontFileID] INT            NULL,
    [IsDeleted]          BIT            NULL,
    [TimeStampModified]  TIMESTAMP      NULL,
    [LastModifiedBy]     NVARCHAR (255) NULL,
    [Action]             NVARCHAR (255) NULL
);


GO
PRINT N'Creating Index [dbo].[tblFontFilesMap].[IXFK_tblFontFilesMap_tblConfigurations]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblFontFilesMap_tblConfigurations]
    ON [dbo].[tblFontFilesMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblFontFilesMap].[IXFK_tblFontFilesMap_tblFontFiles]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblFontFilesMap_tblFontFiles]
    ON [dbo].[tblFontFilesMap]([FontFileID] ASC);


GO
PRINT N'Creating Table [dbo].[tblFontMap]...';


GO
CREATE TABLE [dbo].[tblFontMap] (
    [ConfigurationID]   INT           NULL,
    [FontID]            INT           NULL,
    [PreviousFontID]    INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NOT NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblFontMarker]...';


GO
CREATE TABLE [dbo].[tblFontMarker] (
    [FontMarkerID] INT            NOT NULL,
    [MarkerID]     INT            NOT NULL,
    [Filename]     NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblFontMarker] PRIMARY KEY CLUSTERED ([FontMarkerID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFontMarkerMap]...';


GO
CREATE TABLE [dbo].[tblFontMarkerMap] (
    [ConfigurationID]      INT           NOT NULL,
    [FontMarkerID]         INT           NULL,
    [PreviousFontMarkerID] INT           NULL,
    [isDeleted]            BIT           NULL,
    [TimeStampModified]    TIMESTAMP     NULL,
    [LastModifiedBy]       NVARCHAR (50) NULL,
    [Action]               NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblFontTextEffect]...';


GO
CREATE TABLE [dbo].[tblFontTextEffect] (
    [FontTextEffectID] INT            NOT NULL,
    [Name]             NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblFontTextEffect] PRIMARY KEY CLUSTERED ([FontTextEffectID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblFontTextEffectMap]...';


GO
CREATE TABLE [dbo].[tblFontTextEffectMap] (
    [ConfigurationID]          INT           NULL,
    [FontTextEffectID]         INT           NULL,
    [PreviousFontTextEffectID] INT           NULL,
    [IsDeleted]                BIT           NULL,
    [TimeStampModified]        TIMESTAMP     NULL,
    [LastModifiedBy]           NVARCHAR (50) NULL,
    [Action]                   NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblGeoRef]...';


GO
CREATE TABLE [dbo].[tblGeoRef] (
    [ID]                      INT            IDENTITY (1, 1) NOT NULL,
    [GeoRefId]                INT            NOT NULL,
    [Description]             NVARCHAR (255) NULL,
    [NgaUfiId]                INT            NULL,
    [NgaUniId]                INT            NULL,
    [UsgsFeatureId]           INT            NULL,
    [UnCodeId]                INT            NULL,
    [SequenceId]              INT            NULL,
    [CatTypeId]               INT            NULL,
    [AsxiCatTypeId]           INT            NULL,
    [PnType]                  INT            NULL,
    [RegionId]                INT            NULL,
    [CountryId]               INT            NULL,
    [StateId]                 CHAR (2)       NULL,
    [TZStripId]               INT            NULL,
    [isAirport]               BIT            NOT NULL,
    [isAirportPoi]            BIT            NOT NULL,
    [isAttraction]            BIT            NOT NULL,
    [isCapitalCountry]        BIT            NOT NULL,
    [isCapitalState]          BIT            NOT NULL,
    [isClosestPoi]            BIT            NOT NULL,
    [isControversial]         BIT            NOT NULL,
    [isInteractivePoi]        BIT            NOT NULL,
    [isInteractiveSearch]     BIT            NOT NULL,
    [isMakkahPoi]             BIT            NOT NULL,
    [isRliPoi]                BIT            NOT NULL,
    [isShipWreck]             BIT            NOT NULL,
    [isSnapshot]              BIT            NOT NULL,
    [isSummit]                BIT            NOT NULL,
    [isTerrainLand]           BIT            NOT NULL,
    [isTerrainOcean]          BIT            NOT NULL,
    [isTimeZonePoi]           BIT            NOT NULL,
    [isWaterBody]             BIT            NOT NULL,
    [isWorldClockPoi]         BIT            NOT NULL,
    [isWGuide]                BIT            NOT NULL,
    [Priority]                INT            NULL,
    [AsxiPriority]            INT            NULL,
    [MarkerId]                INT            NULL,
    [AtlasMarkerId]           INT            NULL,
    [MapStatsAppearance]      INT            NULL,
    [PoiPanelStatsAppearance] INT            NULL,
    [RliAppearance]           INT            NULL,
    [KeepNew]                 BIT            NOT NULL,
    [Display]                 BIT            NOT NULL,
    [CustomChangeBitMask]     INT            NOT NULL,
    CONSTRAINT [PK_tblGeoRefItems] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblGeoRefMap]...';


GO
CREATE TABLE [dbo].[tblGeoRefMap] (
    [ConfigurationID]   INT           NOT NULL,
    [GeoRefID]          INT           NOT NULL,
    [PreviousGeoRefID]  INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblGeoRefMap].[IXFK_tblGeoRef_tblACEConfiguration]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblGeoRef_tblACEConfiguration]
    ON [dbo].[tblGeoRefMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblGeoRefMap].[IXFK_tblGeoRef_tblConfigurationReferences]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblGeoRef_tblConfigurationReferences]
    ON [dbo].[tblGeoRefMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblGeoRefMap].[IXFK_tblGeoRef_tblGeoRefItems]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblGeoRef_tblGeoRefItems]
    ON [dbo].[tblGeoRefMap]([GeoRefID] ASC);


GO
PRINT N'Creating Table [dbo].[tblGlobalConfigurationMapping]...';


GO
CREATE TABLE [dbo].[tblGlobalConfigurationMapping] (
    [GlobalConfigurationMappingID] INT NOT NULL,
    [GlobalID]                     INT NULL,
    [ConfigurationDefinitionID]    INT NULL,
    [MappingIndex]                 INT NULL,
    CONSTRAINT [PK_tblGlobalConfigurationMapping] PRIMARY KEY CLUSTERED ([GlobalConfigurationMappingID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblGlobals]...';


GO
CREATE TABLE [dbo].[tblGlobals] (
    [GlobalID]    INT            NOT NULL,
    [Name]        NVARCHAR (255) NULL,
    [Description] NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblGlobals] PRIMARY KEY CLUSTERED ([GlobalID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblHistory]...';


GO
CREATE TABLE [dbo].[tblHistory] (
    [HistoryID]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [RowID]          BIGINT         NOT NULL,
    [ParentRowID]    BIGINT         NULL,
    [Notes]          NVARCHAR (255) NULL,
    [TableName]      NVARCHAR (100) NOT NULL,
    [Timestamp]      TIMESTAMP      NOT NULL,
    [LastModifiedBy] NVARCHAR (50)  NOT NULL,
    [Action]         NVARCHAR (50)  NULL,
    CONSTRAINT [PK_tblHistory] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblInfoSpelling]...';


GO
CREATE TABLE [dbo].[tblInfoSpelling]
(
	[InfoSpellingId] int NOT NULL IDENTITY,
	[InfoId] int NOT NULL,
	[LanguageId] int NOT NULL,
	[Spelling] nvarchar(max) NULL, 
    CONSTRAINT [PK_tblInfoSpelling_InfoSpellingID] PRIMARY KEY ([InfoSpellingID])
);


GO
PRINT N'Creating Table [dbo].[tblInfoSpellingMap]...';


GO
CREATE TABLE [dbo].[tblInfoSpellingMap]
(
	[ConfigurationID] int NULL,
	[InfoSpellingID] int NULL,
	[PreviousInfoSpellingID] int NULL,
	[IsDeleted] bit NULL,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL, 
    CONSTRAINT [FK_tblInfoSpellingMap_tblInfoSpelling] FOREIGN KEY ([InfoSpellingID]) REFERENCES [dbo].[tblInfoSpelling]([InfoSpellingID])
);


GO
PRINT N'Creating Table [dbo].[tblIpadConfig]...';


GO
CREATE TABLE [dbo].[tblIpadConfig] (
    [IpadConfigID] INT IDENTITY (1, 1) NOT NULL,
    [IpadConfig]   XML NULL,
    CONSTRAINT [PK_tblIpadConfig] PRIMARY KEY CLUSTERED ([IpadConfigID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblIpadConfigMap]...';


GO
CREATE TABLE [dbo].[tblIpadConfigMap] (
    [ConfigurationID]      INT           NULL,
    [IpadConfigID]         INT           NULL,
    [PreviousIpadConfigID] INT           NULL,
    [IsDeleted]            BIT           NULL,
    [TimeStampModified]    TIMESTAMP     NOT NULL,
    [LastModifiedBy]       NVARCHAR (50) NULL,
    [Action]               NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblLanguages]...';


GO
CREATE TABLE [dbo].[tblLanguages] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [LanguageID]       INT            NOT NULL,
    [Name]             NVARCHAR (100) NULL,
    [NativeName]       NVARCHAR (100) NULL,
    [Description]      NVARCHAR (255) NULL,
    [ISLatinScript]    BIT            NULL,
    [Tier]             SMALLINT       NULL,
    [2LetterID_4xxx]   NVARCHAR (50)  NULL,
    [3LetterID_4xxx]   NVARCHAR (50)  NULL,
    [2LetterID_ASXi]   NVARCHAR (50)  NULL,
    [3LetterID_ASXi]   NVARCHAR (50)  NULL,
    [HorizontalOrder]  SMALLINT       NULL,
    [HorizontalScroll] SMALLINT       NULL,
    [VerticalOrder]    SMALLINT       NULL,
    [VerticalScroll]   SMALLINT       NULL,
    CONSTRAINT [PK_tblLanguages] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblLanguagesMap]...';


GO
CREATE TABLE [dbo].[tblLanguagesMap] (
    [ConfigurationID]    INT           NULL,
    [LanguageID]         INT           NULL,
    [PreviousLanguageID] INT           NULL,
    [IsDeleted]          BIT           NULL,
    [TimeStampModified]  TIMESTAMP     NOT NULL,
    [LastModifiedBy]     NVARCHAR (50) NULL,
    [Action]             NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblMapInsets]...';


GO
CREATE TABLE [dbo].[tblMapInsets] (
    [MapInsetsID] INT IDENTITY (1, 1) NOT NULL,
    [MapInsets]   XML NULL,
    CONSTRAINT [PK_tblMapInsets] PRIMARY KEY CLUSTERED ([MapInsetsID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblMapInsetsMap]...';


GO
CREATE TABLE [dbo].[tblMapInsetsMap] (
    [ConfigurationID]     INT           NULL,
    [MapInsetsID]         INT           NULL,
    [PreviousMapInsetsID] INT           NULL,
    [IsDeleted]           BIT           NULL,
    [TimeStampModified]   TIMESTAMP     NOT NULL,
    [LastModifiedBy]      NVARCHAR (50) NULL,
    [Action]              NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblMetroMapGeoRefs]...';


GO
CREATE TABLE [dbo].[tblMetroMapGeoRefs] (
    [MetroMapID]      INT            IDENTITY (1, 1) NOT NULL,
    [GeoRefID]        INT            NULL,
    [Description]     NVARCHAR (255) NULL,
    [Priority]        SMALLINT       NULL,
    [MarkerId]        INT            NULL,
    [AtlasMarkerID]   INT            NULL,
    [FontID]          INT            NULL,
    [SphereMapFontID] INT            NULL,
    CONSTRAINT [PK_tblMetroMapGeoRefs] PRIMARY KEY CLUSTERED ([MetroMapID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblMetroMapGeoRefsMap]...';


GO
CREATE TABLE [dbo].[tblMetroMapGeoRefsMap] (
    [ConfigurationID]    INT           NULL,
    [MetroMapID]         INT           NULL,
    [PreviousMetroMapID] INT           NULL,
    [IsDeleted]          BIT           NULL,
    [TimeStampModified]  TIMESTAMP     NOT NULL,
    [LastModifiedBy]     NVARCHAR (50) NULL,
    [Action]             NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblMetroMapGeoRefsMap].[IXFK_MetroMapGeoRefsMap_tblConfigurationReferences]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_MetroMapGeoRefsMap_tblConfigurationReferences]
    ON [dbo].[tblMetroMapGeoRefsMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblMetroMapGeoRefsMap].[IXFK_MetroMapGeoRefsMap_tblMetroMapGeoRefs]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_MetroMapGeoRefsMap_tblMetroMapGeoRefs]
    ON [dbo].[tblMetroMapGeoRefsMap]([MetroMapID] ASC);


GO
PRINT N'Creating Table [dbo].[tblOutputTypes]...';


GO
CREATE TABLE [dbo].[tblOutputTypes] (
    [OutputTypeID]   INT            NOT NULL,
    [OutputTypeName] NVARCHAR (100) NULL,
    CONSTRAINT [PK_tblOutputTypes] PRIMARY KEY CLUSTERED ([OutputTypeID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblPlatformConfigurationMapping]...';


GO
CREATE TABLE [dbo].[tblPlatformConfigurationMapping] (
    [PlatformID]                INT NULL,
    [ConfigurationDefinitionID] INT NULL
);


GO
PRINT N'Creating Table [dbo].[tblPlatforms]...';


GO
CREATE TABLE [dbo].[tblPlatforms] (
    [PlatformID]         INT              NOT NULL,
    [Name]               NVARCHAR (100)   NULL,
    [Description]        NVARCHAR (255)   NULL,
    [InstallationTypeID] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_tblPlatforms] PRIMARY KEY CLUSTERED ([PlatformID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblProductConfigurationMapping]...';


GO
CREATE TABLE [dbo].[tblProductConfigurationMapping] (
    [ProductID]                 INT NULL,
    [ConfigurationDefinitionID] INT NULL
);


GO
PRINT N'Creating Table [dbo].[tblProducts]...';


GO
CREATE TABLE [dbo].[tblProducts] (
    [ProductID]         INT            NOT NULL,
    [Name]              NVARCHAR (255) NULL,
    [Description]       NVARCHAR (255) NULL,
    [TimeStampModified] TIMESTAMP      NULL,
    [LastModifiedBy]    NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblProducts] PRIMARY KEY CLUSTERED ([ProductID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblProductType]...';


GO
CREATE TABLE [dbo].[tblProductType] (
    [ProductTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (50) NULL,
    CONSTRAINT [PK_tblProductType] PRIMARY KEY CLUSTERED ([ProductTypeID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblRegionSpelling]...';


GO
CREATE TABLE [dbo].[tblRegionSpelling] (
    [SpellingID] INT            IDENTITY (1, 1) NOT NULL,
    [RegionID]   INT            NULL,
    [RegionName] NVARCHAR (255) NULL,
    [LanguageId] INT            NULL,
    CONSTRAINT [PK_tblRegionSpelling] PRIMARY KEY CLUSTERED ([SpellingID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblRegionSpellingMap]...';


GO
CREATE TABLE [dbo].[tblRegionSpellingMap] (
    [ConfigurationID]    INT           NULL,
    [SpellingID]         INT           NULL,
    [PreviousSpellingID] INT           NULL,
    [isDeleted]          BIT           NULL,
    [TimeStampModified]  TIMESTAMP     NULL,
    [LastModifiedBy]     NVARCHAR (50) NULL,
    [Action]             NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblRegionSpellingMap].[IXFK_tblRegionSpellingMap_tblConfigurationReferences]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblRegionSpellingMap_tblConfigurationReferences]
    ON [dbo].[tblRegionSpellingMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblRegionSpellingMap].[IXFK_tblRegionSpellingMap_tblRegionSpelling]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblRegionSpellingMap_tblRegionSpelling]
    ON [dbo].[tblRegionSpellingMap]([SpellingID] ASC);


GO
PRINT N'Creating Table [dbo].[tblScreenSize]...';


GO
CREATE TABLE [dbo].[tblScreenSize] (
    [ScreenSizeID] INT            NOT NULL,
    [Description]  NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblScreenSize] PRIMARY KEY CLUSTERED ([ScreenSizeID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblScreenSizeMap]...';


GO
CREATE TABLE [dbo].[tblScreenSizeMap] (
    [ConfigurationID]                INT           NULL,
    [ScreenSizeID]                   INT           NULL,
    [PreviousScreenSizeID]           INT           NULL,
    [IsDeleted]                      BIT           NULL,
    [TimeStampModified]              TIMESTAMP     NOT NULL,
    [LastModifiedBy]                 NVARCHAR (50) NULL,
    [Action]                         NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblSpelling]...';


GO
CREATE TABLE [dbo].[tblSpelling] (
    [SpellingID]        INT            IDENTITY (1, 1) NOT NULL,
    [GeoRefID]          INT            NULL,
    [LanguageID]        INT            NULL,
    [UnicodeStr]        NVARCHAR (255) NULL,
    [POISpelling]       NVARCHAR (255) NULL,
    [FontID]            INT            NULL,
    [SphereMapFontID]   INT            NULL,
    [DataSourceID]      INT            NULL,
    [TimeStampModified] TIMESTAMP      NOT NULL,
    [SourceDate]        DATE           NULL,
    [DoSpellCheck]      BIT            NULL,
    CONSTRAINT [PK_tblSpelling] PRIMARY KEY CLUSTERED ([SpellingID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblSpellingMap]...';


GO
CREATE TABLE [dbo].[tblSpellingMap] (
    [ConfigurationID]    INT           NULL,
    [SpellingID]         INT           NULL,
    [PreviousSpellingID] INT           NULL,
    [IsDeleted]          BIT           NULL,
    [TimeStampModified]  TIMESTAMP     NULL,
    [LastModifiedBy]     NVARCHAR (50) NULL,
    [Action]             NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblSpellingMap].[IXFK_tblSpellingMap_tblConfigurationReferences]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblSpellingMap_tblConfigurationReferences]
    ON [dbo].[tblSpellingMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblSpellingMap].[IXFK_tblSpellingMap_tblSpelling]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblSpellingMap_tblSpelling]
    ON [dbo].[tblSpellingMap]([SpellingID] ASC);


GO
PRINT N'Creating Table [dbo].[tblSpellingPoiPanel]...';


GO
CREATE TABLE [dbo].[tblSpellingPoiPanel] (
    [SpellingID]        INT            IDENTITY (1, 1) NOT NULL,
    [GeoRefId]          INT            NULL,
    [Description]       NVARCHAR (255) NULL,
    [TimeStampModified] TIMESTAMP      NOT NULL,
    [SourceDate]        DATETIME       NULL,
    [lang_ar]           NVARCHAR (255) NULL,
    [lang_az]           NVARCHAR (255) NULL,
    [lang_bn]           NVARCHAR (255) NULL,
    [lang_bo]           NVARCHAR (255) NULL,
    [lang_da]           NVARCHAR (255) NULL,
    [lang_de]           NVARCHAR (255) NULL,
    [lang_di]           NVARCHAR (255) NULL,
    [lang_el]           NVARCHAR (255) NULL,
    [lang_en]           NVARCHAR (255) NULL,
    [lang_ep]           NVARCHAR (255) NULL,
    [lang_es]           NVARCHAR (255) NULL,
    [lang_fi]           NVARCHAR (255) NULL,
    [lang_fr]           NVARCHAR (255) NULL,
    [lang_he]           NVARCHAR (255) NULL,
    [lang_hi]           NVARCHAR (255) NULL,
    [lang_hk]           NVARCHAR (255) NULL,
    [lang_hu]           NVARCHAR (255) NULL,
    [lang_id]           NVARCHAR (255) NULL,
    [lang_is]           NVARCHAR (255) NULL,
    [lang_it]           NVARCHAR (255) NULL,
    [lang_ja]           NVARCHAR (255) NULL,
    [lang_kk]           NVARCHAR (255) NULL,
    [lang_ko]           NVARCHAR (255) NULL,
    [lang_mn]           NVARCHAR (255) NULL,
    [lang_ms]           NVARCHAR (255) NULL,
    [lang_nl]           NVARCHAR (255) NULL,
    [lang_pl]           NVARCHAR (255) NULL,
    [lang_pt]           NVARCHAR (255) NULL,
    [lang_ro]           NVARCHAR (255) NULL,
    [lang_ru]           NVARCHAR (255) NULL,
    [lang_sm]           NVARCHAR (255) NULL,
    [lang_sp]           NVARCHAR (255) NULL,
    [lang_sr]           NVARCHAR (255) NULL,
    [lang_sv]           NVARCHAR (255) NULL,
    [lang_th]           NVARCHAR (255) NULL,
    [lang_tk]           NVARCHAR (255) NULL,
    [lang_to]           NVARCHAR (255) NULL,
    [lang_tr]           NVARCHAR (255) NULL,
    [lang_uz]           NVARCHAR (255) NULL,
    [lang_vi]           NVARCHAR (255) NULL,
    [lang_lk]           NVARCHAR (255) NULL,
    [lang_zh]           NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblSpellingPoiPanel] PRIMARY KEY CLUSTERED ([SpellingID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblSpellingPoiPanelMap]...';


GO
CREATE TABLE [dbo].[tblSpellingPoiPanelMap] (
    [ConfigurationID]    INT           NULL,
    [SpellingID]         INT           NULL,
    [PreviousSpellingID] INT           NULL,
    [IsDeleted]          BIT           NULL,
    [TimeStampModified]  TIMESTAMP     NULL,
    [LastModifiedBy]     NVARCHAR (50) NULL,
    [Action]             NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblSpellingPoiPanelMap].[IXFK_tblSpellingPoiPanelMap_tblConfigurationReferences]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblSpellingPoiPanelMap_tblConfigurationReferences]
    ON [dbo].[tblSpellingPoiPanelMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblSpellingPoiPanelMap].[IXFK_tblSpellingPoiPanelMap_tblSpellingPoiPanel]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblSpellingPoiPanelMap_tblSpellingPoiPanel]
    ON [dbo].[tblSpellingPoiPanelMap]([SpellingID] ASC);


GO
PRINT N'Creating Table [dbo].[tblSubscription]...';


GO
CREATE TABLE [dbo].[tblSubscription] (
    [ID]               UNIQUEIDENTIFIER NOT NULL,
    [Name]             NVARCHAR (50)    NULL,
    [Description]      NVARCHAR (500)   NULL,
    [IsObsolete]       BIT              NULL,
    [DateCreated]      DATETIME         NULL,
    [DateLastModified] TIMESTAMP        NULL,
    CONSTRAINT [PK_tblSubscription] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblSubscriptionFeature]...';


GO
CREATE TABLE [dbo].[tblSubscriptionFeature] (
    [ID]               UNIQUEIDENTIFIER NOT NULL,
    [Name]             NVARCHAR (50)    NULL,
    [Description]      NVARCHAR (50)    NULL,
    [DefaultJSON]      NVARCHAR (MAX)   NULL,
    [EditorJSONSchema] NVARCHAR (MAX)   NULL,
    [IsObsolete]       BIT              NULL,
    CONSTRAINT [PK_tblSubscriptionFeature] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblSubscriptionFeatureAssignment]...';


GO
CREATE TABLE [dbo].[tblSubscriptionFeatureAssignment] (
    [ID]                    UNIQUEIDENTIFIER NOT NULL,
    [SubscriptionID]        UNIQUEIDENTIFIER NULL,
    [SubscriptionFeatureID] UNIQUEIDENTIFIER NULL,
    [ConfigurationJSON]     NVARCHAR (MAX)   NULL,
    CONSTRAINT [PK_tblSubscriptionFeatureAssignment] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblTaskData]...';


GO
CREATE TABLE [dbo].[tblTaskData] (
    [ID]             UNIQUEIDENTIFIER NOT NULL,
    [TaskID]         UNIQUEIDENTIFIER NULL,
    [TaskDataTypeID] UNIQUEIDENTIFIER NULL,
    [StringData]     NVARCHAR (50)    NULL,
    CONSTRAINT [PK_TaskData] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblTaskDataType]...';


GO
CREATE TABLE [dbo].[tblTaskDataType] (
    [ID]          UNIQUEIDENTIFIER NOT NULL,
    [Name]        NVARCHAR (50)    NULL,
    [Description] NVARCHAR (50)    NULL,
    CONSTRAINT [PK_TaskDataType] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblTasks]...';


GO
CREATE TABLE [dbo].[tblTasks] (
    [ID]                        UNIQUEIDENTIFIER NOT NULL,
    [TaskTypeID]                UNIQUEIDENTIFIER NULL,
    [StartedByUserID]           UNIQUEIDENTIFIER NULL,
    [TaskStatusID]              INT              NULL,
    [DateStarted]               DATETIME         NULL,
    [DateLastUpdated]           DATETIME         NULL,
    [PercentageComplete]        FLOAT (53)       NULL,
    [DetailedStatus]            NVARCHAR (50)    NULL,
    [AzureBuildID]              INT              NULL,
    [AircraftID]                UNIQUEIDENTIFIER NULL,
    [ConfigurationDefinitionID] INT              NULL,
    [ConfigurationID]           INT              NULL,
    [ErrorLog]                  NVARCHAR (MAX)   NULL,
    [TaskDataJSON]              NVARCHAR (MAX)   NULL,
    CONSTRAINT [PK_tblTasks] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblTaskStatus]...';


GO
CREATE TABLE [dbo].[tblTaskStatus] (
    [ID]          INT           NOT NULL,
    [Name]        NVARCHAR (50) NULL,
    [Description] NVARCHAR (50) NULL,
    CONSTRAINT [PK_TaskStatus] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblTaskType]...';


GO
CREATE TABLE [dbo].[tblTaskType] (
    [ID]                UNIQUEIDENTIFIER NOT NULL,
    [Name]              NVARCHAR (50)    NULL,
    [Description]       NVARCHAR (50)    NULL,
    [AzureDefinitionID] INT              NULL,
    CONSTRAINT [PK_TaskType] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblTimeZoneStrip]...';


GO
CREATE TABLE [dbo].[tblTimeZoneStrip] (
    [ID]          INT            IDENTITY (1, 1) NOT NULL,
    [TZStripID]   INT            NULL,
    [Description] NVARCHAR (255) NULL,
    [IdVer1]      INT            NULL,
    [IdVer2]      INT            NULL,
    CONSTRAINT [PK_tblTimeZoneStrip] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblTimeZoneStripMap]...';


GO
CREATE TABLE [dbo].[tblTimeZoneStripMap] (
    [ConfigurationID]         INT           NULL,
    [TimeZoneStripID]          INT           NULL,
    [PreviousTimeZoneStripID] INT           NULL,
    [IsDeleted]               BIT           NULL,
    [TimeStampModified]       TIMESTAMP     NULL,
    [LastModifiedBy]          NVARCHAR (50) NULL,
    [Action]                  NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblTimeZoneStripMap].[IXFK_tblTimeZoneStripMap_tblConfigurationReferences]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblTimeZoneStripMap_tblConfigurationReferences]
    ON [dbo].[tblTimeZoneStripMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblTimeZoneStripMap].[IXFK_tblTimeZoneStripMap_tblTimeZoneStrip]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblTimeZoneStripMap_tblTimeZoneStrip]
    ON [dbo].[tblTimeZoneStripMap]([TimeZoneStripID] ASC);


GO
PRINT N'Creating Table [dbo].[UserClaims]...';


GO
CREATE TABLE [dbo].[UserClaims] (
    [ID]          UNIQUEIDENTIFIER NOT NULL,
    [Name]        NVARCHAR (50)    NOT NULL,
    [Description] NVARCHAR (50)    NULL,
    [ScopeType]   NVARCHAR (50)    NULL,
    CONSTRAINT [PK_dbo.UserClaims] PRIMARY KEY CLUSTERED ([ID] ASC, [Name] ASC)
);


GO
PRINT N'Creating Table [dbo].[UserRoleAssignments]...';


GO
CREATE TABLE [dbo].[UserRoleAssignments] (
    [ID]     UNIQUEIDENTIFIER NOT NULL,
    [UserID] UNIQUEIDENTIFIER NOT NULL,
    [RoleID] UNIQUEIDENTIFIER NULL
);


GO
PRINT N'Creating Table [dbo].[UserRoleClaims]...';


GO
CREATE TABLE [dbo].[UserRoleClaims] (
    [ID]                        UNIQUEIDENTIFIER NOT NULL,
    [RoleID]                    UNIQUEIDENTIFIER NULL,
    [ClaimID]                   UNIQUEIDENTIFIER NULL,
    [AircraftID]                UNIQUEIDENTIFIER NULL,
    [UserRoleID]                UNIQUEIDENTIFIER NULL,
    [ConfigurationID]           INT              NULL,
    [ConfigurationDefinitionID] INT              NULL,
    [OperatorID]                UNIQUEIDENTIFIER NULL,
    [ServiceID]                 UNIQUEIDENTIFIER NULL,
    [ProductTypeID]             INT              NULL,
    CONSTRAINT [PK_UserRoleClaims] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[UserRoles]...';


GO
CREATE TABLE [dbo].[UserRoles] (
    [ID]          UNIQUEIDENTIFIER NOT NULL,
    [Name]        NVARCHAR (50)    NOT NULL,
    [Description] NVARCHAR (50)    NULL,
    [Hidden]      BIT              NULL,
    [ThirdParty]  BIT              NULL,
    CONSTRAINT [PK_dbo.UserRoles] PRIMARY KEY CLUSTERED ([ID] ASC, [Name] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblUSStates]...';


GO
CREATE TABLE [dbo].[tblUSStates] (
    [StateID]   NVARCHAR (2)  NOT NULL,
    [StateName] NVARCHAR (50) NULL,
    CONSTRAINT [PK_tblUsStates] PRIMARY KEY CLUSTERED ([StateID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblUSStatesMap]...';


GO
CREATE TABLE [dbo].[tblUSStatesMap] (
    [ConfigurationID]   INT           NOT NULL,
    [StateID]           NVARCHAR (2)  NULL,
    [PreviousStateID]   INT           NULL,
    [isDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Index [dbo].[tblUSStatesMap].[IXFK_tblUSStatesMap_tblConfigurations]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblUSStatesMap_tblConfigurations]
    ON [dbo].[tblUSStatesMap]([ConfigurationID] ASC);


GO
PRINT N'Creating Index [dbo].[tblUSStatesMap].[IXFK_tblUSStatesMap_tblUSStates]...';


GO
CREATE NONCLUSTERED INDEX [IXFK_tblUSStatesMap_tblUSStates]
    ON [dbo].[tblUSStatesMap]([StateID] ASC);


GO
PRINT N'Creating Table [dbo].[tblWGContent]...';


GO
CREATE TABLE [dbo].[tblWGContent] (
    [WGContentID] INT IDENTITY (1, 1) NOT NULL,
    [GeoRefID]    INT NULL,
    [TypeID]      INT NULL,
    [ImageID]     INT NULL,
    [TextID]      INT NULL,
    CONSTRAINT [PK_tblWGContent] PRIMARY KEY CLUSTERED ([WGContentID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblWGContentMap]...';


GO
CREATE TABLE [dbo].[tblWGContentMap] (
    [ConfigurationID]     INT           NULL,
    [WGContentID]         INT           NULL,
    [PreviousWGContentID] INT           NULL,
    [IsDeleted]           BIT           NULL,
    [TimeStampModified]   TIMESTAMP     NOT NULL,
    [LastModifiedBy]      NVARCHAR (50) NULL,
    [Action]              NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblWGImage]...';


GO
CREATE TABLE [dbo].[tblWGImage] (
    [ID]       INT            IDENTITY (1, 1) NOT NULL,
    [ImageID]  INT            NOT NULL,
    [FileName] NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblWGImage] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblWGImageMap]...';


GO
CREATE TABLE [dbo].[tblWGImageMap] (
    [ConfigurationID]   INT           NULL,
    [ImageID]           INT           NULL,
    [PreviousImageID]   INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NOT NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblWGtext]...';


GO
CREATE TABLE [dbo].[tblWGtext] (
    [WGtextID] INT            IDENTITY (1, 1) NOT NULL,
    [TextID]   INT            NULL,
    [Text_EN]  NVARCHAR (MAX) NULL,
    [Text_FR]  NVARCHAR (MAX) NULL,
    [Text_DE]  NVARCHAR (MAX) NULL,
    [Text_ES]  NVARCHAR (MAX) NULL,
    [Text_NL]  NVARCHAR (MAX) NULL,
    [Text_IT]  NVARCHAR (MAX) NULL,
    [Text_EL]  NVARCHAR (MAX) NULL,
    [Text_JA]  NVARCHAR (MAX) NULL,
    [Text_ZH]  NVARCHAR (MAX) NULL,
    [Text_KO]  NVARCHAR (MAX) NULL,
    [Text_ID]  NVARCHAR (MAX) NULL,
    [Text_AR]  NVARCHAR (MAX) NULL,
    [Text_TR]  NVARCHAR (MAX) NULL,
    [Text_MS]  NVARCHAR (MAX) NULL,
    [Text_FI]  NVARCHAR (MAX) NULL,
    [Text_HI]  NVARCHAR (MAX) NULL,
    [Text_RU]  NVARCHAR (MAX) NULL,
    [Text_PT]  NVARCHAR (MAX) NULL,
    [Text_TH]  NVARCHAR (MAX) NULL,
    [Text_RO]  NVARCHAR (MAX) NULL,
    [Text_SR]  NVARCHAR (MAX) NULL,
    [Text_SV]  NVARCHAR (MAX) NULL,
    [Text_HU]  NVARCHAR (MAX) NULL,
    [Text_HE]  NVARCHAR (MAX) NULL,
    [Text_PL]  NVARCHAR (MAX) NULL,
    [Text_HK]  NVARCHAR (MAX) NULL,
    [Text_SM]  NVARCHAR (MAX) NULL,
    [Text_TO]  NVARCHAR (MAX) NULL,
    [Text_CS]  NVARCHAR (MAX) NULL,
    [Text_DA]  NVARCHAR (MAX) NULL,
    [Text_IS]  NVARCHAR (MAX) NULL,
    [Text_VI]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_tblWGtext] PRIMARY KEY CLUSTERED ([WGtextID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblWGtextMap]...';


GO
CREATE TABLE [dbo].[tblWGtextMap] (
    [ConfigurationID]   INT           NULL,
    [WGtextID]          INT           NULL,
    [PreviousWGtextID]  INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblWGType]...';


GO
CREATE TABLE [dbo].[tblWGType] (
    [WGTypeID]    INT            IDENTITY (1, 1) NOT NULL,
    [TypeID]      INT            NULL,
    [Description] NVARCHAR (255) NULL,
    [Layout]      INT            NULL,
    [ImageWidth]  INT            NULL,
    [ImageHeight] INT            NULL,
    CONSTRAINT [PK_tbWGType] PRIMARY KEY CLUSTERED ([WGTypeID] ASC)
);


GO
PRINT N'Creating Table [dbo].[tblWGTypeMap]...';


GO
CREATE TABLE [dbo].[tblWGTypeMap] (
    [ConfigurationID]   INT           NULL,
    [WGTypeID]          INT           NULL,
    [PreviousWGTypeID]  INT           NULL,
    [IsDeleted]         BIT           NULL,
    [TimeStampModified] TIMESTAMP     NULL,
    [LastModifiedBy]    NVARCHAR (50) NULL,
    [Action]            NVARCHAR (50) NULL
);


GO
PRINT N'Creating Table [dbo].[tblNavDBAirports]...';


GO
CREATE TABLE [dbo].[tblNavDBAirports]
(
	[FourLetId] NVARCHAR(10) NULL , 
    [ThreeLetId] NVARCHAR(10) NULL, 
    [Lat] NVARCHAR(50) NULL, 
    [Long] NVARCHAR(50) NULL, 
    [Description] NVARCHAR(250) NULL, 
    [City] NVARCHAR(50) NULL, 
    [SN] INT NULL, 
    [existingGeorefId] INT NULL
);


GO
PRINT N'Creating Table [dbo].[tblConfigurationHistory]...';


GO
CREATE TABLE [dbo].[tblConfigurationHistory] (
    [ConfigurationHistoryID] INT                IDENTITY (1, 1) NOT NULL,
    [ConfigurationID]        INT                NULL,
    [UserComments]           NVARCHAR (MAX)     NULL,
    [TimeStampCommentAdded]  ROWVERSION         NOT NULL,
    [CommentAddedBy]         NVARCHAR (50)      NULL,
    [Action]                 NVARCHAR (50)      NULL,
    [ContentType]            NVARCHAR (50)      NULL,
    [DateModified]           DATETIME           NULL,
    [TaskID]                 UNIQUEIDENTIFIER   NULL,
    CONSTRAINT [PK_tblConfigurationHistory] PRIMARY KEY CLUSTERED ([ConfigurationHistoryID] ASC)
);


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblMapsMap]...';


GO
ALTER TABLE [cust].[tblMapsMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblMakkahMap]...';


GO
ALTER TABLE [cust].[tblMakkahMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblHtml5Map]...';


GO
ALTER TABLE [cust].[tblHtml5Map]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblHandSetMap]...';


GO
ALTER TABLE [cust].[tblHandSetMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblGlobalMap]...';


GO
ALTER TABLE [cust].[tblGlobalMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblResolutionMap]...';


GO
ALTER TABLE [cust].[tblResolutionMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblPersonalityListMap]...';


GO
ALTER TABLE [cust].[tblPersonalityListMap]
    ADD DEFAULT 0 FOR [isDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblNewsMap]...';


GO
ALTER TABLE [cust].[tblNewsMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblNews]...';


GO
ALTER TABLE [cust].[tblNews]
    ADD DEFAULT NULL FOR [News];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblModeDefsMap]...';


GO
ALTER TABLE [cust].[tblModeDefsMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblModeDefs]...';


GO
ALTER TABLE [cust].[tblModeDefs]
    ADD DEFAULT NULL FOR [ModeDefs];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblMiqatMap]...';


GO
ALTER TABLE [cust].[tblMiqatMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblMenuMap]...';


GO
ALTER TABLE [cust].[tblMenuMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblMenu]...';


GO
ALTER TABLE [cust].[tblMenu]
    ADD DEFAULT 0 FOR [IsHTML5];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblTimeZoneGlobePlaceNamesMap]...';


GO
ALTER TABLE [cust].[tblTimeZoneGlobePlaceNamesMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblTickerMap]...';


GO
ALTER TABLE [cust].[tblTickerMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblScriptDefsMap]...';


GO
ALTER TABLE [cust].[tblScriptDefsMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblScriptDefs]...';


GO
ALTER TABLE [cust].[tblScriptDefs]
    ADD DEFAULT NULL FOR [ScriptDefs];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblRLIMap]...';


GO
ALTER TABLE [cust].[tblRLIMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblWebMainMap]...';


GO
ALTER TABLE [cust].[tblWebMainMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO

PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblTriggerMap]...';


GO
ALTER TABLE [cust].[tblTriggerMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblWorldTimeZonePlaceNamesMap]...';


GO
ALTER TABLE [cust].[tblWorldTimeZonePlaceNamesMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblWorldMapPlaceNamesMap]...';


GO
ALTER TABLE [cust].[tblWorldMapPlaceNamesMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblWorldMapCitiesMap]...';


GO
ALTER TABLE [cust].[tblWorldMapCitiesMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [cust].[tblWorldClockCitiesMap]...';


GO
ALTER TABLE [cust].[tblWorldClockCitiesMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO

GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblAirportInfoMap]...';


GO
ALTER TABLE [dbo].[tblAirportInfoMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblAppearance]...';


GO
ALTER TABLE [dbo].[tblAppearance]
    ADD DEFAULT 0 FOR [CustomChangeBitMask];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblAppearanceMap]...';


GO
ALTER TABLE [dbo].[tblAppearanceMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblAreaMap]...';


GO
ALTER TABLE [dbo].[tblAreaMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblAsxiProfileMap]...';


GO
ALTER TABLE [dbo].[tblAsxiProfileMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblAsxiWorldGuideText]...';


GO
ALTER TABLE [dbo].[tblAsxiWorldGuideText]
    ADD DEFAULT 0 FOR [DoSpellCheck];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblAsxiWorldGuideTextMap]...';


GO
ALTER TABLE [dbo].[tblAsxiWorldGuideTextMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblCategoryType]...';


GO
ALTER TABLE [dbo].[tblCategoryType]
    ADD DEFAULT NULL FOR [GeoRefCategoryTypeID_ASXIAndroid];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblCityPopulationMap]...';


GO
ALTER TABLE [dbo].[tblCityPopulationMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblConfigurationComponentsMap]...';


GO
ALTER TABLE [dbo].[tblConfigurationComponentsMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblCountryMap]...';


GO
ALTER TABLE [dbo].[tblCountryMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblCountrySpelling]...';


GO
ALTER TABLE [dbo].[tblCountrySpelling]
    ADD DEFAULT 0 FOR [doSpellCheck];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblCountrySpellingMap]...';


GO
ALTER TABLE [dbo].[tblCountrySpellingMap]
    ADD DEFAULT -1 FOR [PreviousCountrySpellingID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblCountrySpellingMap]...';


GO
ALTER TABLE [dbo].[tblCountrySpellingMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblCoverageSegment]...';


GO
ALTER TABLE [dbo].[tblCoverageSegment]
    ADD DEFAULT 0 FOR [CustomChangeBitMask];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblCoverageSegmentMap]...';


GO
ALTER TABLE [dbo].[tblCoverageSegmentMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblElevationMap]...';


GO
ALTER TABLE [dbo].[tblElevationMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontCategory]...';


GO
ALTER TABLE [dbo].[tblFontCategory]
    ADD DEFAULT 0 FOR [GeoRefIdCatTypeID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontCategory]...';


GO
ALTER TABLE [dbo].[tblFontCategory]
    ADD DEFAULT 0 FOR [LanguageID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontCategoryMap]...';


GO
ALTER TABLE [dbo].[tblFontCategoryMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontDefaultCategoryMap]...';


GO
ALTER TABLE [dbo].[tblFontDefaultCategoryMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontFamilyMap]...';


GO
ALTER TABLE [dbo].[tblFontFamilyMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontMap]...';


GO
ALTER TABLE [dbo].[tblFontMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontMarker]...';


GO
ALTER TABLE [dbo].[tblFontMarker]
    ADD DEFAULT 0 FOR [MarkerID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontMarkerMap]...';


GO
ALTER TABLE [dbo].[tblFontMarkerMap]
    ADD DEFAULT -1 FOR [PreviousFontMarkerID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontMarkerMap]...';


GO
ALTER TABLE [dbo].[tblFontMarkerMap]
    ADD DEFAULT 0 FOR [isDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontTextEffectMap]...';


GO
ALTER TABLE [dbo].[tblFontTextEffectMap]
    ADD DEFAULT -1 FOR [PreviousFontTextEffectID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblFontTextEffectMap]...';


GO
ALTER TABLE [dbo].[tblFontTextEffectMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isAirport];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isAirportPoi];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isAttraction];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isCapitalCountry];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isCapitalState];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isClosestPoi];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isControversial];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isInteractivePoi];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isInteractiveSearch];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isMakkahPoi];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isRliPoi];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isShipWreck];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isSnapshot];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isSummit];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isTerrainLand];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isTerrainOcean];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isTimeZonePoi];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isWaterBody];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isWorldClockPoi];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [isWGuide];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [KeepNew];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [Display];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRef]...';


GO
ALTER TABLE [dbo].[tblGeoRef]
    ADD DEFAULT 0 FOR [CustomChangeBitMask];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblGeoRefMap]...';


GO
ALTER TABLE [dbo].[tblGeoRefMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblLanguages]...';


GO
ALTER TABLE [dbo].[tblLanguages]
    ADD DEFAULT 0 FOR [HorizontalOrder];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblLanguages]...';


GO
ALTER TABLE [dbo].[tblLanguages]
    ADD DEFAULT 0 FOR [HorizontalScroll];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblLanguages]...';


GO
ALTER TABLE [dbo].[tblLanguages]
    ADD DEFAULT 0 FOR [VerticalOrder];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblLanguages]...';


GO
ALTER TABLE [dbo].[tblLanguages]
    ADD DEFAULT 0 FOR [VerticalScroll];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblLanguagesMap]...';


GO
ALTER TABLE [dbo].[tblLanguagesMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblMapInsetsMap]...';


GO
ALTER TABLE [dbo].[tblMapInsetsMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblMetroMapGeoRefsMap]...';


GO
ALTER TABLE [dbo].[tblMetroMapGeoRefsMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblRegionSpellingMap]...';


GO
ALTER TABLE [dbo].[tblRegionSpellingMap]
    ADD DEFAULT -1 FOR [PreviousSpellingID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblRegionSpellingMap]...';


GO
ALTER TABLE [dbo].[tblRegionSpellingMap]
    ADD DEFAULT 0 FOR [isDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblScreenSizeMap]...';


GO
ALTER TABLE [dbo].[tblScreenSizeMap]
    ADD DEFAULT -1 FOR [PreviousScreenSizeID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblScreenSizeMap]...';


GO
ALTER TABLE [dbo].[tblScreenSizeMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblSpelling]...';


GO
ALTER TABLE [dbo].[tblSpelling]
    ADD DEFAULT 0 FOR [DoSpellCheck];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblSpellingMap]...';


GO
ALTER TABLE [dbo].[tblSpellingMap]
    ADD DEFAULT -1 FOR [PreviousSpellingID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblSpellingMap]...';


GO
ALTER TABLE [dbo].[tblSpellingMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblSpellingPoiPanelMap]...';


GO
ALTER TABLE [dbo].[tblSpellingPoiPanelMap]
    ADD DEFAULT -1 FOR [PreviousSpellingID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblSpellingPoiPanelMap]...';


GO
ALTER TABLE [dbo].[tblSpellingPoiPanelMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblTimeZoneStripMap]...';


GO
ALTER TABLE [dbo].[tblTimeZoneStripMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblUSStatesMap]...';


GO
ALTER TABLE [dbo].[tblUSStatesMap]
    ADD DEFAULT -1 FOR [PreviousStateID];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblUSStatesMap]...';


GO
ALTER TABLE [dbo].[tblUSStatesMap]
    ADD DEFAULT 0 FOR [isDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblWGContentMap]...';


GO
ALTER TABLE [dbo].[tblWGContentMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblWGImageMap]...';


GO
ALTER TABLE [dbo].[tblWGImageMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblWGtextMap]...';


GO
ALTER TABLE [dbo].[tblWGtextMap]
    ADD DEFAULT 0 FOR [IsDeleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[tblWGTypeMap]...';


GO
ALTER TABLE [dbo].[tblWGTypeMap]
    ADD DEFAULT 0 FOR [IsDeleted];

GO
PRINT N'Creating Foreign Key [dbo].[tblImage]...';

GO
ALTER TABLE [dbo].[tblImage]
 ADD CONSTRAINT FK_tblImage_tblImageType FOREIGN KEY(ImageTypeId) REFERENCES tblImageType(ID);
GO

PRINT N'Creating Foreign Key [dbo].[tblImageResSpec]...';

GO
ALTER TABLE [dbo].[tblImageResSpec]
ADD 
  CONSTRAINT FK_tblImageResSpec_tblImage FOREIGN KEY(ImageId) REFERENCES tblImage(ImageId);
GO
  ALTER TABLE [dbo].[tblImageResSpec]  WITH CHECK ADD  CONSTRAINT [FK_tblImageResSpec_tblConfigurations] FOREIGN KEY([ConfigurationID])
REFERENCES [dbo].[tblConfigurations] ([ConfigurationID])

GO

PRINT N'Creating Foreign Key [dbo].[tblImageMap]...';

GO
ALTER TABLE [dbo].[tblImageMap]
ADD 
  CONSTRAINT FK_tblImageMap_tblImage FOREIGN KEY(ImageId) REFERENCES tblImage(ImageId);
ALTER TABLE [dbo].[tblImageMap]  WITH CHECK ADD  CONSTRAINT [FK_tblImageMap_tblConfigurations] FOREIGN KEY([ConfigurationID])
REFERENCES [dbo].[tblConfigurations] ([ConfigurationID])
GO

PRINT N'Creating Foreign Key [cust].[FK_tblFlyOverAlertMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblFlyOverAlertMap]
    ADD CONSTRAINT [FK_tblFlyOverAlertMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblFlyOverAlertMap_tblFlyOverAlert]...';


GO
ALTER TABLE [cust].[tblFlyOverAlertMap]
    ADD CONSTRAINT [FK_tblFlyOverAlertMap_tblFlyOverAlert] FOREIGN KEY ([FlyOverAlertID]) REFERENCES [cust].[tblFlyOverAlert] ([FlyOverAlertID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblMapsMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblMapsMap]
    ADD CONSTRAINT [FK_tblMapsMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblMapsMap_tblMaps]...';


GO
ALTER TABLE [cust].[tblMapsMap]
    ADD CONSTRAINT [FK_tblMapsMap_tblMaps] FOREIGN KEY ([MapID]) REFERENCES [cust].[tblMaps] ([MapID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblMakkahMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblMakkahMap]
    ADD CONSTRAINT [FK_tblMakkahMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblMakkahMap_tblMakkah]...';


GO
ALTER TABLE [cust].[tblMakkahMap]
    ADD CONSTRAINT [FK_tblMakkahMap_tblMakkah] FOREIGN KEY ([MakkahID]) REFERENCES [cust].[tblMakkah] ([MakkahID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblhtml5Map_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblHtml5Map]
    ADD CONSTRAINT [FK_tblhtml5Map_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblHtml5Map_tblHtml5]...';


GO
ALTER TABLE [cust].[tblHtml5Map]
    ADD CONSTRAINT [FK_tblHtml5Map_tblHtml5] FOREIGN KEY ([Html5ID]) REFERENCES [cust].[tblHtml5] ([Html5ID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblHandSetMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblHandSetMap]
    ADD CONSTRAINT [FK_tblHandSetMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblHandSetMap_tblHandSet]...';


GO
ALTER TABLE [cust].[tblHandSetMap]
    ADD CONSTRAINT [FK_tblHandSetMap_tblHandSet] FOREIGN KEY ([HandSetID]) REFERENCES [cust].[tblHandSet] ([HandSetID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblCustomMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblGlobalMap]
    ADD CONSTRAINT [FK_tblCustomMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblCustomMap_tblCustom]...';


GO
ALTER TABLE [cust].[tblGlobalMap]
    ADD CONSTRAINT [FK_tblCustomMap_tblCustom] FOREIGN KEY ([CustomID]) REFERENCES [cust].[tblGlobal] ([CustomID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblResolutionMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblResolutionMap]
    ADD CONSTRAINT [FK_tblResolutionMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblResolutionMap_tblResolution]...';


GO
ALTER TABLE [cust].[tblResolutionMap]
    ADD CONSTRAINT [FK_tblResolutionMap_tblResolution] FOREIGN KEY ([ResolutionID]) REFERENCES [cust].[tblResolution] ([ResolutionID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblPersonalityListMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblPersonalityListMap]
    ADD CONSTRAINT [FK_tblPersonalityListMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblPersonalityListMap_tblPersonalityList]...';


GO
ALTER TABLE [cust].[tblPersonalityListMap]
    ADD CONSTRAINT [FK_tblPersonalityListMap_tblPersonalityList] FOREIGN KEY ([PersonalityListID]) REFERENCES [cust].[tblPersonalityList] ([PersonalityListID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblNewsMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblNewsMap]
    ADD CONSTRAINT [FK_tblNewsMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblNewsMap_tblNews]...';


GO
ALTER TABLE [cust].[tblNewsMap]
    ADD CONSTRAINT [FK_tblNewsMap_tblNews] FOREIGN KEY ([NewsID]) REFERENCES [cust].[tblNews] ([NewsID]);


GO
PRINT N'Creating Foreign Key [cust].[FK_tblModeDefsMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblModeDefsMap]
    ADD CONSTRAINT [FK_tblModeDefsMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblModeDefsMap_tblModeDefs]...';


GO
ALTER TABLE [cust].[tblModeDefsMap]
    ADD CONSTRAINT [FK_tblModeDefsMap_tblModeDefs] FOREIGN KEY ([ModeDefID]) REFERENCES [cust].[tblModeDefs] ([ModeDefID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblMiqatMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblMiqatMap]
    ADD CONSTRAINT [FK_tblMiqatMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblMiqatMap_tblMiqat]...';


GO
ALTER TABLE [cust].[tblMiqatMap]
    ADD CONSTRAINT [FK_tblMiqatMap_tblMiqat] FOREIGN KEY ([MiqatID]) REFERENCES [cust].[tblMiqat] ([MiqatID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblMenuMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblMenuMap]
    ADD CONSTRAINT [FK_tblMenuMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblMenuMap_tblMenu]...';


GO
ALTER TABLE [cust].[tblMenuMap]
    ADD CONSTRAINT [FK_tblMenuMap_tblMenu] FOREIGN KEY ([MenuID]) REFERENCES [cust].[tblMenu] ([MenuID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblTimeZoneGlobePlaceNamesMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblTimeZoneGlobePlaceNamesMap]
    ADD CONSTRAINT [FK_tblTimeZoneGlobePlaceNamesMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblTimeZoneGlobePlaceNamesMap_tblTimeZoneGlobePlaceNames]...';


GO
ALTER TABLE [cust].[tblTimeZoneGlobePlaceNamesMap]
    ADD CONSTRAINT [FK_tblTimeZoneGlobePlaceNamesMap_tblTimeZoneGlobePlaceNames] FOREIGN KEY ([PlaceNameID]) REFERENCES [cust].[tblTimeZoneGlobePlaceNames] ([PlaceNameID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblTickerMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblTickerMap]
    ADD CONSTRAINT [FK_tblTickerMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblTickerMap_tblTicker]...';


GO
ALTER TABLE [cust].[tblTickerMap]
    ADD CONSTRAINT [FK_tblTickerMap_tblTicker] FOREIGN KEY ([TickerID]) REFERENCES [cust].[tblTicker] ([TickerID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblScriptDefsMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblScriptDefsMap]
    ADD CONSTRAINT [FK_tblScriptDefsMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblScriptDefsMap_tblScriptDefs]...';


GO
ALTER TABLE [cust].[tblScriptDefsMap]
    ADD CONSTRAINT [FK_tblScriptDefsMap_tblScriptDefs] FOREIGN KEY ([ScriptDefID]) REFERENCES [cust].[tblScriptDefs] ([ScriptDefID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblRLIMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblRLIMap]
    ADD CONSTRAINT [FK_tblRLIMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblRLIMap_tblRli]...';


GO
ALTER TABLE [cust].[tblRLIMap]
    ADD CONSTRAINT [FK_tblRLIMap_tblRli] FOREIGN KEY ([RLIID]) REFERENCES [cust].[tblRli] ([RLIID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblInfoItemsMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblWebMainMap]
    ADD CONSTRAINT [FK_tblInfoItemsMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWebMainMap_tblWebMain]...';


GO
ALTER TABLE [cust].[tblWebMainMap]
    ADD CONSTRAINT [FK_tblWebMainMap_tblWebMain] FOREIGN KEY ([WebMainID]) REFERENCES [cust].[tblWebMain] ([WebMainID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblTzPoisMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblTzPoisMap]
    ADD CONSTRAINT [FK_tblTzPoisMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;

PRINT N'Creating Foreign Key [cust].[FK_tblTzPoisMap_tblTzPois]...';


GO
ALTER TABLE [cust].[tblTzPoisMap]
    ADD CONSTRAINT [FK_tblTzPoisMap_tblTzPois] FOREIGN KEY (TzPoisID) REFERENCES [cust].[tblTzPois] ([TzPoisID]) ON DELETE CASCADE;



GO
PRINT N'Creating Foreign Key [cust].[FK_tblTriggerMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblTriggerMap]
    ADD CONSTRAINT [FK_tblTriggerMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblTriggerMap_tblTrigger]...';


GO
ALTER TABLE [cust].[tblTriggerMap]
    ADD CONSTRAINT [FK_tblTriggerMap_tblTrigger] FOREIGN KEY ([TriggerID]) REFERENCES [cust].[tblTrigger] ([TriggerID]);


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWorldTimeZonePlaceNamesMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblWorldTimeZonePlaceNamesMap]
    ADD CONSTRAINT [FK_tblWorldTimeZonePlaceNamesMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWorldTimeZonePlaceNamesMap_tblWorldTimeZonePlaceNames]...';


GO
ALTER TABLE [cust].[tblWorldTimeZonePlaceNamesMap]
    ADD CONSTRAINT [FK_tblWorldTimeZonePlaceNamesMap_tblWorldTimeZonePlaceNames] FOREIGN KEY ([PlaceNameID]) REFERENCES [cust].[tblWorldTimeZonePlaceNames] ([PlaceNameID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWorldMapPlaceNamesMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblWorldMapPlaceNamesMap]
    ADD CONSTRAINT [FK_tblWorldMapPlaceNamesMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWorldMapPlaceNamesMap_tblWorldMapPlaceNames]...';


GO
ALTER TABLE [cust].[tblWorldMapPlaceNamesMap]
    ADD CONSTRAINT [FK_tblWorldMapPlaceNamesMap_tblWorldMapPlaceNames] FOREIGN KEY ([PlaceNameID]) REFERENCES [cust].[tblWorldMapPlaceNames] ([PlaceNameID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWorldMapCitiesMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblWorldMapCitiesMap]
    ADD CONSTRAINT [FK_tblWorldMapCitiesMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWorldMapCitiesMap_tblWorldMapCities]...';


GO
ALTER TABLE [cust].[tblWorldMapCitiesMap]
    ADD CONSTRAINT [FK_tblWorldMapCitiesMap_tblWorldMapCities] FOREIGN KEY ([WorldMapCityID]) REFERENCES [cust].[tblWorldMapCities] ([WorldMapCityID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWorldClockCityMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblWorldClockCitiesMap]
    ADD CONSTRAINT [FK_tblWorldClockCityMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblWorldClockCityMap_WorldClockCities]...';


GO
ALTER TABLE [cust].[tblWorldClockCitiesMap]
    ADD CONSTRAINT [FK_tblWorldClockCityMap_WorldClockCities] FOREIGN KEY ([WorldClockCityID]) REFERENCES [cust].[tblWorldClockCities] ([WorldClockCityID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [cust].[FK_tblConfigVersionMap_tblConfigurations]...';


GO
ALTER TABLE [cust].[tblConfigVersionMap]
    ADD CONSTRAINT [FK_tblConfigVersionMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]);


GO
PRINT N'Creating Foreign Key [cust].[FK_tblConfigVersionMap_tblConfigVersion]...';


GO
ALTER TABLE [cust].[tblConfigVersionMap]
    ADD CONSTRAINT [FK_tblConfigVersionMap_tblConfigVersion] FOREIGN KEY ([ConfigVersionID]) REFERENCES [cust].[tblConfigVersion] ([ConfigVersionID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAircraftConfigurationMapping_tblConfigurationDefinitions]...';


GO
ALTER TABLE [dbo].[tblAircraftConfigurationMapping]
    ADD CONSTRAINT [FK_tblAircraftConfigurationMapping_tblConfigurationDefinitions] FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE SET NULL;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAirportInfoMap_tblAirportInfo]...';


GO
ALTER TABLE [dbo].[tblAirportInfoMap]
    ADD CONSTRAINT [FK_tblAirportInfoMap_tblAirportInfo] FOREIGN KEY ([AirportInfoID]) REFERENCES [dbo].[tblAirportInfo] ([AirportInfoID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAirportInfoMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblAirportInfoMap]
    ADD CONSTRAINT [FK_tblAirportInfoMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAirshowSubscriptionAssignment_tblConfigurationDefinitions]...';


GO
ALTER TABLE [dbo].[tblAirshowSubscriptionAssignment]
    ADD CONSTRAINT [FK_tblAirshowSubscriptionAssignment_tblConfigurationDefinitions] FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAirshowSubscriptionAssignment_tblSubscription]...';


GO
ALTER TABLE [dbo].[tblAirshowSubscriptionAssignment]
    ADD CONSTRAINT [FK_tblAirshowSubscriptionAssignment_tblSubscription] FOREIGN KEY ([SubscriptionID]) REFERENCES [dbo].[tblSubscription] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAppearanceMap_tblAppearance]...';


GO
ALTER TABLE [dbo].[tblAppearanceMap]
    ADD CONSTRAINT [FK_tblAppearanceMap_tblAppearance] FOREIGN KEY ([AppearanceID]) REFERENCES [dbo].[tblAppearance] ([AppearanceID]) ON DELETE CASCADE;



GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAreaMap_tblArea]...';


GO
ALTER TABLE [dbo].[tblAreaMap]
    ADD CONSTRAINT [FK_tblAreaMap_tblArea] FOREIGN KEY ([AreaID]) REFERENCES [dbo].[tblArea] ([AreaID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAreaMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblAreaMap]
    ADD CONSTRAINT [FK_tblAreaMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblASXiInsetMap_tblASXiInset]...';


GO
ALTER TABLE [dbo].[tblASXiInsetMap]
    ADD CONSTRAINT [FK_tblASXiInsetMap_tblASXiInset] FOREIGN KEY ([ASXiInsetID]) REFERENCES [dbo].[tblASXiInset] ([ASXiInsetID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblASXiInsetMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblASXiInsetMap]
    ADD CONSTRAINT [FK_tblASXiInsetMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAsxiProfileMap_tblAsxiProfile]...';


GO
ALTER TABLE [dbo].[tblAsxiProfileMap]
    ADD CONSTRAINT [FK_tblAsxiProfileMap_tblAsxiProfile] FOREIGN KEY ([AsxiProfileID]) REFERENCES [dbo].[tblAsxiProfile] ([AsxiProfileID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAsxiProfileMap_tblConfigurations_copy]...';


GO
ALTER TABLE [dbo].[tblAsxiProfileMap]
    ADD CONSTRAINT [FK_tblAsxiProfileMap_tblConfigurations_copy] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAsxiWorldGuidTextMap_tblAsxiWorldGuideText]...';


GO
ALTER TABLE [dbo].[tblAsxiWorldGuideTextMap]
    ADD CONSTRAINT [FK_tblAsxiWorldGuidTextMap_tblAsxiWorldGuideText] FOREIGN KEY ([AsxiWorldGuideTextID]) REFERENCES [dbo].[tblAsxiWorldGuideText] ([AsxiWorldGuideTextID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblAsxiWorldGuidTextMap_tblConfiguration]...';


GO
ALTER TABLE [dbo].[tblAsxiWorldGuideTextMap]
    ADD CONSTRAINT [FK_tblAsxiWorldGuidTextMap_tblConfiguration] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblCityPopulationMap_tblCityPopulation]...';


GO
ALTER TABLE [dbo].[tblCityPopulationMap]
    ADD CONSTRAINT [FK_tblCityPopulationMap_tblCityPopulation] FOREIGN KEY ([CityPopulationID]) REFERENCES [dbo].[tblCityPopulation] ([CityPopulationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblCityPopulationMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblCityPopulationMap]
    ADD CONSTRAINT [FK_tblCityPopulationMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblConfigurationComponents_tblConfigurationComponentType]...';


GO
ALTER TABLE [dbo].[tblConfigurationComponents]
    ADD CONSTRAINT [FK_tblConfigurationComponents_tblConfigurationComponentType] FOREIGN KEY ([ConfigurationComponentTypeID]) REFERENCES [dbo].[tblConfigurationComponentType] ([ConfigurationComponentTypeID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tbconfigCompMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblConfigurationComponentsMap]
    ADD CONSTRAINT [FK_tbconfigCompMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblConfigurationComponentsMap_tblConfigurationComponents_02]...';


GO
ALTER TABLE [dbo].[tblConfigurationComponentsMap]
    ADD CONSTRAINT [FK_tblConfigurationComponentsMap_tblConfigurationComponents_02] FOREIGN KEY ([ConfigurationComponentID]) REFERENCES [dbo].[tblConfigurationComponents] ([ConfigurationComponentID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblConfigurationDefinitions_tblConfigurationTypes]...';


GO
ALTER TABLE [dbo].[tblConfigurationDefinitions]
    ADD CONSTRAINT [FK_tblConfigurationDefinitions_tblConfigurationTypes] FOREIGN KEY ([ConfigurationTypeID]) REFERENCES [dbo].[tblConfigurationTypes] ([ConfigurationTypeID]) ON DELETE SET NULL;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblConfigurationDefinitions_tblOutputTypes]...';


GO
ALTER TABLE [dbo].[tblConfigurationDefinitions]
    ADD CONSTRAINT [FK_tblConfigurationDefinitions_tblOutputTypes] FOREIGN KEY ([OutputTypeID]) REFERENCES [dbo].[tblOutputTypes] ([OutputTypeID]) ON DELETE SET NULL;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblConfigurations_tblConfigurationDefinitions]...';


GO
ALTER TABLE [dbo].[tblConfigurations]
    ADD CONSTRAINT [FK_tblConfigurations_tblConfigurationDefinitions] FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE SET NULL;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblCountryMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblCountryMap]
    ADD CONSTRAINT [FK_tblCountryMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblCountryMap_tblCountry]...';


GO
ALTER TABLE [dbo].[tblCountryMap]
    ADD CONSTRAINT [FK_tblCountryMap_tblCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[tblCountry] ([CountryID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblCountrySpelling_tblCountry]...';


GO
ALTER TABLE [dbo].[tblCountrySpelling]
    ADD CONSTRAINT [FK_tblCountrySpelling_tblCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[tblCountry] ([CountryID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_CountrySpellingMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblCountrySpellingMap]
    ADD CONSTRAINT [FK_CountrySpellingMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_CountrySpellingMap_tblCountrySpelling]...';


GO
ALTER TABLE [dbo].[tblCountrySpellingMap]
    ADD CONSTRAINT [FK_CountrySpellingMap_tblCountrySpelling] FOREIGN KEY ([CountrySpellingID]) REFERENCES [dbo].[tblCountrySpelling] ([CountrySpellingID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblCoverageSegmentMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblCoverageSegmentMap]
    ADD CONSTRAINT [FK_tblCoverageSegmentMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblCoverageSegmentMap_tblCoverageSegment]...';


GO
ALTER TABLE [dbo].[tblCoverageSegmentMap]
    ADD CONSTRAINT [FK_tblCoverageSegmentMap_tblCoverageSegment] FOREIGN KEY ([CoverageSegmentID]) REFERENCES [dbo].[tblCoverageSegment] ([ID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblElevationMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblElevationMap]
    ADD CONSTRAINT [FK_tblElevationMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblElevationMap_tblElevation]...';


GO
ALTER TABLE [dbo].[tblElevationMap]
    ADD CONSTRAINT [FK_tblElevationMap_tblElevation] FOREIGN KEY ([ElevationID]) REFERENCES [dbo].[tblElevation] ([ID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFleetConfigurationMapping_tblConfigurationDefinitions]...';


GO
ALTER TABLE [dbo].[tblFleetConfigurationMapping]
    ADD CONSTRAINT [FK_tblFleetConfigurationMapping_tblConfigurationDefinitions] FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE SET NULL;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFleetConfigurationMapping_tblFleets]...';


GO
ALTER TABLE [dbo].[tblFleetConfigurationMapping]
    ADD CONSTRAINT [FK_tblFleetConfigurationMapping_tblFleets] FOREIGN KEY ([FleetID]) REFERENCES [dbo].[tblFleets] ([FleetID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontCategoryMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblFontCategoryMap]
    ADD CONSTRAINT [FK_tblFontCategoryMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontCategoryMap_tblFontCategory]...';


GO
ALTER TABLE [dbo].[tblFontCategoryMap]
    ADD CONSTRAINT [FK_tblFontCategoryMap_tblFontCategory] FOREIGN KEY ([FontCategoryID]) REFERENCES [dbo].[tblFontCategory] ([FontCategoryID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontDefaultCategoryMap_tblFontDefaultCategory]...';


GO
ALTER TABLE [dbo].[tblFontDefaultCategoryMap]
    ADD CONSTRAINT [FK_tblFontDefaultCategoryMap_tblFontDefaultCategory] FOREIGN KEY ([FontDefaultCategoryID]) REFERENCES [dbo].[tblFontDefaultCategory] ([FontDefaultCategoryID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontFamilyMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblFontFamilyMap]
    ADD CONSTRAINT [FK_tblFontFamilyMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontFamilyMap_tblFontFamily]...';


GO
ALTER TABLE [dbo].[tblFontFamilyMap]
    ADD CONSTRAINT [FK_tblFontFamilyMap_tblFontFamily] FOREIGN KEY ([FontFamilyID]) REFERENCES [dbo].[tblFontFamily] ([FontFamilyID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontFileSelectionMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblFontFileSelectionMap]
    ADD CONSTRAINT [FK_tblFontFileSelectionMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontFileSelectionMap_tblFontFileSelection]...';


GO
ALTER TABLE [dbo].[tblFontFileSelectionMap]
    ADD CONSTRAINT [FK_tblFontFileSelectionMap_tblFontFileSelection] FOREIGN KEY ([FontFileSelectionID]) REFERENCES [dbo].[tblFontFileSelection] ([FontFileSelectionID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontFilesMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblFontFilesMap]
    ADD CONSTRAINT [FK_tblFontFilesMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontFilesMap_tblFontFiles]...';


GO
ALTER TABLE [dbo].[tblFontFilesMap]
    ADD CONSTRAINT [FK_tblFontFilesMap_tblFontFiles] FOREIGN KEY ([FontFileID]) REFERENCES [dbo].[tblFontFiles] ([FontFileID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblFontMap]
    ADD CONSTRAINT [FK_tblFontMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontMap_tblFont]...';


GO
ALTER TABLE [dbo].[tblFontMap]
    ADD CONSTRAINT [FK_tblFontMap_tblFont] FOREIGN KEY ([FontID]) REFERENCES [dbo].[tblFont] ([FontID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontMarkerMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblFontMarkerMap]
    ADD CONSTRAINT [FK_tblFontMarkerMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontMarkerMap_tblFontMarker]...';


GO
ALTER TABLE [dbo].[tblFontMarkerMap]
    ADD CONSTRAINT [FK_tblFontMarkerMap_tblFontMarker] FOREIGN KEY ([FontMarkerID]) REFERENCES [dbo].[tblFontMarker] ([FontMarkerID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontTextEffectMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblFontTextEffectMap]
    ADD CONSTRAINT [FK_tblFontTextEffectMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblFontTextEffectMap_tblFontTextEffect]...';


GO
ALTER TABLE [dbo].[tblFontTextEffectMap]
    ADD CONSTRAINT [FK_tblFontTextEffectMap_tblFontTextEffect] FOREIGN KEY ([FontTextEffectID]) REFERENCES [dbo].[tblFontTextEffect] ([FontTextEffectID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblGeoRef_tblConfigurationReferences]...';


GO
ALTER TABLE [dbo].[tblGeoRefMap]
    ADD CONSTRAINT [FK_tblGeoRef_tblConfigurationReferences] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblGeoRef_tblGeoRefItems]...';


GO
ALTER TABLE [dbo].[tblGeoRefMap]
    ADD CONSTRAINT [FK_tblGeoRef_tblGeoRefItems] FOREIGN KEY ([GeoRefID]) REFERENCES [dbo].[tblGeoRef] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblGlobalConfigurationMapping_tblConfigurationDefinitions]...';


GO
ALTER TABLE [dbo].[tblGlobalConfigurationMapping]
    ADD CONSTRAINT [FK_tblGlobalConfigurationMapping_tblConfigurationDefinitions] FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE SET NULL;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblGlobalConfigurationMapping_tblGlobals]...';


GO
ALTER TABLE [dbo].[tblGlobalConfigurationMapping]
    ADD CONSTRAINT [FK_tblGlobalConfigurationMapping_tblGlobals] FOREIGN KEY ([GlobalID]) REFERENCES [dbo].[tblGlobals] ([GlobalID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblIpadConfigMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblIpadConfigMap]
    ADD CONSTRAINT [FK_tblIpadConfigMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblIpadConfigMap_tblIpadConfig]...';


GO
ALTER TABLE [dbo].[tblIpadConfigMap]
    ADD CONSTRAINT [FK_tblIpadConfigMap_tblIpadConfig] FOREIGN KEY ([IpadConfigID]) REFERENCES [dbo].[tblIpadConfig] ([IpadConfigID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblLanguagesMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblLanguagesMap]
    ADD CONSTRAINT [FK_tblLanguagesMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblLanguagesMap_tblLanguages]...';


GO
ALTER TABLE [dbo].[tblLanguagesMap]
    ADD CONSTRAINT [FK_tblLanguagesMap_tblLanguages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[tblLanguages] ([ID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblMapInsetsMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblMapInsetsMap]
    ADD CONSTRAINT [FK_tblMapInsetsMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblMapInsetsMap_tblMapInsets]...';


GO
ALTER TABLE [dbo].[tblMapInsetsMap]
    ADD CONSTRAINT [FK_tblMapInsetsMap_tblMapInsets] FOREIGN KEY ([MapInsetsID]) REFERENCES [dbo].[tblMapInsets] ([MapInsetsID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_MetroMapGeoRefsMap_tblConfiguration]...';


GO
ALTER TABLE [dbo].[tblMetroMapGeoRefsMap]
    ADD CONSTRAINT [FK_MetroMapGeoRefsMap_tblConfiguration] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_MetroMapGeoRefsMap_tblMetroMapGeoRefs]...';


GO
ALTER TABLE [dbo].[tblMetroMapGeoRefsMap]
    ADD CONSTRAINT [FK_MetroMapGeoRefsMap_tblMetroMapGeoRefs] FOREIGN KEY ([MetroMapID]) REFERENCES [dbo].[tblMetroMapGeoRefs] ([MetroMapID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblPlatformConfigurationMapping_tblConfigurationDefinitions]...';


GO
ALTER TABLE [dbo].[tblPlatformConfigurationMapping]
    ADD CONSTRAINT [FK_tblPlatformConfigurationMapping_tblConfigurationDefinitions] FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE SET NULL;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblPlatformConfigurationMapping_tblPlatforms]...';


GO
ALTER TABLE [dbo].[tblPlatformConfigurationMapping]
    ADD CONSTRAINT [FK_tblPlatformConfigurationMapping_tblPlatforms] FOREIGN KEY ([PlatformID]) REFERENCES [dbo].[tblPlatforms] ([PlatformID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblPlatforms_InstallationTypes]...';


GO
ALTER TABLE [dbo].[tblPlatforms]
    ADD CONSTRAINT [FK_tblPlatforms_InstallationTypes] FOREIGN KEY ([InstallationTypeID]) REFERENCES [dbo].[InstallationTypes] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblProductConfigurationMapping_tblConfigurationDefinitions]...';


GO
ALTER TABLE [dbo].[tblProductConfigurationMapping]
    ADD CONSTRAINT [FK_tblProductConfigurationMapping_tblConfigurationDefinitions] FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblProductConfigurationMapping_tblProducts]...';


GO
ALTER TABLE [dbo].[tblProductConfigurationMapping]
    ADD CONSTRAINT [FK_tblProductConfigurationMapping_tblProducts] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[tblProducts] ([ProductID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblRegionSpellingMap_tblConfiguration]...';


GO
ALTER TABLE [dbo].[tblRegionSpellingMap]
    ADD CONSTRAINT [FK_tblRegionSpellingMap_tblConfiguration] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblRegionSpellingMap_tblRegionSpelling]...';


GO
ALTER TABLE [dbo].[tblRegionSpellingMap]
    ADD CONSTRAINT [FK_tblRegionSpellingMap_tblRegionSpelling] FOREIGN KEY ([SpellingID]) REFERENCES [dbo].[tblRegionSpelling] ([SpellingID]) ON UPDATE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblScreenSizeMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblScreenSizeMap]
    ADD CONSTRAINT [FK_tblScreenSizeMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblScreenSizeMap_tblScreenSize]...';


GO
ALTER TABLE [dbo].[tblScreenSizeMap]
    ADD CONSTRAINT [FK_tblScreenSizeMap_tblScreenSize] FOREIGN KEY ([ScreenSizeID]) REFERENCES [dbo].[tblScreenSize] ([ScreenSizeID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblSpellingMap_tblConfiguration]...';


GO
ALTER TABLE [dbo].[tblSpellingMap]
    ADD CONSTRAINT [FK_tblSpellingMap_tblConfiguration] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblSpellingMap_tblSpelling]...';


GO
ALTER TABLE [dbo].[tblSpellingMap]
    ADD CONSTRAINT [FK_tblSpellingMap_tblSpelling] FOREIGN KEY ([SpellingID]) REFERENCES [dbo].[tblSpelling] ([SpellingID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblSpellingPoiPanelMap_tblConfiguration]...';


GO
ALTER TABLE [dbo].[tblSpellingPoiPanelMap]
    ADD CONSTRAINT [FK_tblSpellingPoiPanelMap_tblConfiguration] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblSpellingPoiPanelMap_tblSpellingPoiPanel]...';


GO
ALTER TABLE [dbo].[tblSpellingPoiPanelMap]
    ADD CONSTRAINT [FK_tblSpellingPoiPanelMap_tblSpellingPoiPanel] FOREIGN KEY ([SpellingID]) REFERENCES [dbo].[tblSpellingPoiPanel] ([SpellingID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblSubscriptionFeatureAssignment_tblSubscription]...';


GO
ALTER TABLE [dbo].[tblSubscriptionFeatureAssignment]
    ADD CONSTRAINT [FK_tblSubscriptionFeatureAssignment_tblSubscription] FOREIGN KEY ([SubscriptionID]) REFERENCES [dbo].[tblSubscription] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblSubscriptionFeatureAssignment_tblSubscriptionFeature]...';


GO
ALTER TABLE [dbo].[tblSubscriptionFeatureAssignment]
    ADD CONSTRAINT [FK_tblSubscriptionFeatureAssignment_tblSubscriptionFeature] FOREIGN KEY ([SubscriptionFeatureID]) REFERENCES [dbo].[tblSubscriptionFeature] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_TaskData _TaskDataType]...';


GO
ALTER TABLE [dbo].[tblTaskData]
    ADD CONSTRAINT [FK_TaskData _TaskDataType] FOREIGN KEY ([TaskDataTypeID]) REFERENCES [dbo].[tblTaskDataType] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_TaskData _tblTasks]...';


GO
ALTER TABLE [dbo].[tblTaskData]
    ADD CONSTRAINT [FK_TaskData _tblTasks] FOREIGN KEY ([TaskID]) REFERENCES [dbo].[tblTasks] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblTasks_TaskStatus]...';


GO
ALTER TABLE [dbo].[tblTasks]
    ADD CONSTRAINT [FK_tblTasks_TaskStatus] FOREIGN KEY ([TaskStatusID]) REFERENCES [dbo].[tblTaskStatus] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblTasks_TaskType]...';


GO
ALTER TABLE [dbo].[tblTasks]
    ADD CONSTRAINT [FK_tblTasks_TaskType] FOREIGN KEY ([TaskTypeID]) REFERENCES [dbo].[tblTaskType] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblTimeZoneStripMap_tblConfiguration]...';


GO
ALTER TABLE [dbo].[tblTimeZoneStripMap]
    ADD CONSTRAINT [FK_tblTimeZoneStripMap_tblConfiguration] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblTimeZoneStripMap_tblTimeZoneStrip]...';


GO
ALTER TABLE [dbo].[tblTimeZoneStripMap]
    ADD CONSTRAINT [FK_tblTimeZoneStripMap_tblTimeZoneStrip] FOREIGN KEY ([TimeZoneStripID]) REFERENCES [dbo].[tblTimeZoneStrip] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_UserRoleClaims_tblConfigurationDefinitions]...';


GO
ALTER TABLE [dbo].[UserRoleClaims]
    ADD CONSTRAINT [FK_UserRoleClaims_tblConfigurationDefinitions] FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_UserRoleClaims_Aircraft]...';


GO
ALTER TABLE [dbo].[UserRoleClaims]
    ADD CONSTRAINT [FK_UserRoleClaims_Aircraft] FOREIGN KEY ([AircraftID]) REFERENCES [dbo].[Aircraft] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_UserRoleClaims_Operator]...';


GO
ALTER TABLE [dbo].[UserRoleClaims]
    ADD CONSTRAINT [FK_UserRoleClaims_Operator] FOREIGN KEY ([OperatorID]) REFERENCES [dbo].[Operator] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_UserRoleClaims_tblConfigurations]...';


GO
ALTER TABLE [dbo].[UserRoleClaims]
    ADD CONSTRAINT [FK_UserRoleClaims_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_UserRoleClaims_tblProductType]...';


GO
ALTER TABLE [dbo].[UserRoleClaims]
    ADD CONSTRAINT [FK_UserRoleClaims_tblProductType] FOREIGN KEY ([ProductTypeID]) REFERENCES [dbo].[tblProductType] ([ProductTypeID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblUSStatesMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblUSStatesMap]
    ADD CONSTRAINT [FK_tblUSStatesMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblUSStatesMap_tblUSStates]...';


GO
ALTER TABLE [dbo].[tblUSStatesMap]
    ADD CONSTRAINT [FK_tblUSStatesMap_tblUSStates] FOREIGN KEY ([StateID]) REFERENCES [dbo].[tblUSStates] ([StateID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblWGContentMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblWGContentMap]
    ADD CONSTRAINT [FK_tblWGContentMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblWGContentMap_tblWGContent]...';


GO
ALTER TABLE [dbo].[tblWGContentMap]
    ADD CONSTRAINT [FK_tblWGContentMap_tblWGContent] FOREIGN KEY ([WGContentID]) REFERENCES [dbo].[tblWGContent] ([WGContentID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblWGImageMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblWGImageMap]
    ADD CONSTRAINT [FK_tblWGImageMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblWGImageMap_tblWGImage]...';


GO
ALTER TABLE [dbo].[tblWGImageMap]
    ADD CONSTRAINT [FK_tblWGImageMap_tblWGImage] FOREIGN KEY ([ImageID]) REFERENCES [dbo].[tblWGImage] ([ID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblWGtextMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblWGtextMap]
    ADD CONSTRAINT [FK_tblWGtextMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblWGtextMap_tblWGtext]...';


GO
ALTER TABLE [dbo].[tblWGtextMap]
    ADD CONSTRAINT [FK_tblWGtextMap_tblWGtext] FOREIGN KEY ([WGtextID]) REFERENCES [dbo].[tblWGtext] ([WGtextID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblWGTypeMap_tblConfigurations]...';


GO
ALTER TABLE [dbo].[tblWGTypeMap]
    ADD CONSTRAINT [FK_tblWGTypeMap_tblConfigurations] FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE CASCADE;


GO
PRINT N'Creating Foreign Key [dbo].[FK_tblWGTypeMap_tblWGType]...';


GO
ALTER TABLE [dbo].[tblWGTypeMap]
    ADD CONSTRAINT [FK_tblWGTypeMap_tblWGType] FOREIGN KEY ([WGTypeID]) REFERENCES [dbo].[tblWGType] ([WGTypeID]) ON DELETE CASCADE;


GO
PRINT N'Creating Extended Property [cust].[tblMakkah].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Encapsulates the configuration information for the makkah feature', @level0type = N'SCHEMA', @level0name = N'cust', @level1type = N'TABLE', @level1name = N'tblMakkah';


GO
PRINT N'Creating Extended Property [cust].[tblMiqat].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'captures the configuration information for the miqat feature in ASXi', @level0type = N'SCHEMA', @level0name = N'cust', @level1type = N'TABLE', @level1name = N'tblMiqat';


GO
PRINT N'Creating Extended Property [cust].[tblTrigger].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'triggers are used to describe logic equations that can then be referenced by other systems to control their execution logic.  triggers can currently be associated with autoplay script items to filter them out of the autoplay sequence (the script item only shows up if its associated trigger is "active". Each trigger is defined by a unique id that is referenced elsewhere in the custom.xml file. Name is a description for readability. Type is either "" or "manual" (not used). Condition is the logic equation used for processing (can contain parentheses). The default  attribute describes the default state for the trigger at startup. The following operands can be used within the condition: GE, GT, LE, LT, EQ, NOT, NE, AND, OR   The following values can be referenced within the condition:  GS, ALT, DTD, DFD, TTD, TSD, FLTPHASE, PER, GMT, GMTDATE, DEP, DES, MANTRIG, MIQATPHASE, TYPE, GMTDATERANGE, GMTDWOY, GMTTIMERANGE,     -- DOW, DEST_GROUP, DEPT_GROUP, DEPT_ICAO, DEST_ICAO, ACARSPRESENT, LCLT, PERSONALITY  <trigger_defs>     <trigger id="1" name="Date 20170816 through 20180816" type="" condition="GMTDATE GE 20170816 AND GMTDATE LT 20180816" default="false" />     <trigger id="2" name="Date 20170816 through NA" type="" condition="GMTDATE GE 20170816" default="false" />   </trigger_defs>', @level0type = N'SCHEMA', @level0name = N'cust', @level1type = N'TABLE', @level1name = N'tblTrigger';


GO
PRINT N'Creating Extended Property [dbo].[tblAircraftConfigurationMapping].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This table keeps track of the logical relationships between configurations. For example, there can be multiple versions of a configuration for an aircraft, but they are all versions of the same "configuration". Each configuration reference points to a parent configuration that it inherits values from during the merge function. Each configuration reference also specifies a aircraft that it is a configuration for.   This tells ACE which data is applicable for this configuration and what configuration file outputs should be generated during the build process.  A new row is added to this table whenever we need a new configuration for a new entity in ACE, such as a new aircraft, a new fleet, a new product, or a new platform.   We also add a new row if something fundamental changes about the Airshow configuration for one of those entities, such as when an aircraft changes which Airshow product is installed on that aircraft (i.e. a cabin upgrade that results in a change from AS4000 to ASXi4). Please see the tblAircraftConfigurationMapping table for an example of how this works.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblAircraftConfigurationMapping';


GO
PRINT N'Creating Extended Property [dbo].[tblAppearance].[Resolution].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Map resolution expressed in arcseconds.  A value of 0 indicates N/A.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblAppearance', @level2type = N'COLUMN', @level2name = N'Resolution';


GO
PRINT N'Creating Extended Property [dbo].[tblAppearance].[Exclude].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates whether to hide the place name on 2-D maps.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblAppearance', @level2type = N'COLUMN', @level2name = N'Exclude';


GO
PRINT N'Creating Extended Property [dbo].[tblAppearance].[SphereMapExclude].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates whether to hide the place name on 3-D maps.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblAppearance', @level2type = N'COLUMN', @level2name = N'SphereMapExclude';


GO
PRINT N'Creating Extended Property [dbo].[tblConfigurationDefinitions].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This table defines each configuration and keeps track of the hierarchical relationship between configurations by recording which configuration it inherits from. The individual versions of a particular configuration are recorded elsewhere, in the tblConfigurations table. For example, there can be multiple versions of a configuration for an aircraft, but they are all versions of the same "configuration" defined in this table. Each configuration definition points to a parent configuration that it inherits values from during the merge function. Each configuration definition also specifies a product that it is a configuration for. This tells ACE which data is applicable for this configuration and what outputs should be generated during the build process. A new row is added to this table whenever we need a new configuration for a new entity in ACE, such as a new aircraft, a new fleet, a new product, or a new platform. We also add a new row if something fundamental changes about the Airshow configuration for one of those entities, such as when an aircraft changes which Airshow product is installed on that aircraft (i.e. a cabin upgrade that results in a change from AS4000 to ASXi4). Please see the tblAircraftConfigurationMapping table for an example of how this works.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblConfigurationDefinitions';


GO
PRINT N'Creating Extended Property [dbo].[tblConfigurations].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This table defines each version of a configuration.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblConfigurations';


GO
PRINT N'Creating Extended Property [dbo].[tblConfigurationTypes].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This table specifies the unique configuration requirements for the different Airshow configuration formats. This generally maps to the various Airshow product iterations (e.g. ASXi4, ASXi3, AS4000). Each configuration definition will reference this table to determine which data sets are to be used for merges, as well as what data is displayed within the UX.  Note: The data sets (e.g. timezone, placenames) used for a particular product cannot be changed once it has been set. If a change is needed, then a new Product record needs to be defined. This is needed to prevent changes to locked configurations that referenced the previous product definition. WE SHOULD USE DATABASE TRIGGERS (UPDATE, DELETE) TO PREVENT CHANGES TO ANY RECORD THAT IS REFERENCED BY tblConfigurationReferences.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblConfigurationTypes';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[GeoRefId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Collins Aerospace unique identifier for place names.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'GeoRefId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[NgaUfiId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Place name description; contains some legacy data.  For internal use only.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'NgaUfiId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[NgaUniId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'National Geospatial-Intelligence Agency unique name identifier for non-U.S. place names.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'NgaUniId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[UsgsFeatureId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'U.S.G.S. unique feature identifier for U.S.-based place names.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'UsgsFeatureId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[UnCodeId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'United Nations, Statistics Division unique identifier for place names.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'UnCodeId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[SequenceId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'POI Panel feature media identifier for this place name. Used in (ASX).tbSpelling.SequenceId, (ASX Media).tbSequenceElement.SequenceId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'SequenceId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[CatTypeId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Categorization of this place name.  Used in (ASXi 2D PAC/THA, iPad 1.x).tbgeorefid.GeoRefIdCatTypeId, (CES TSE).tbSpelling.FontId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'CatTypeId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[AsxiCatTypeId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Categorization of this place name for ASXi/Android platforms.  See tbcategorytype.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'AsxiCatTypeId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[PnType].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Dimensional type of this place name.  Values: 1 = point; 2 = line; 3 = polygon.  Used in (ASX).tbGeoRefId.PnType and (AS iPad 1.x).tbgeorefid.PnGeoType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'PnType';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[RegionId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Region assigned to this place name. Used in tbRegionSpelling.RegionId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'RegionId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[CountryId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Country assigned to this place name. Used in tbCountrySpelling.CountryId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'CountryId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[StateId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'U.S. state assigned to this place name. Used in (ASX).tbpnametrivia and tbUsStates.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'StateId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[TZStripId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Time zone strip ID for this place name.  Used in tbTimeZoneStrip.TZStripId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'TZStripId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isAirport].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is an airport.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isAirport';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isAirportPoi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a city associated with an airport.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isAirportPoi';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isAttraction].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a constructed tourist attraction (museum, theme park, etc.).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isAttraction';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isCapitalCountry].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a country capital.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isCapitalCountry';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isCapitalState].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a U.S. state capital.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isCapitalState';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isClosestPoi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available in the "Closest City" list. Used in (ASXi 3D).tbGeoRefId.ClosestPoi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isClosestPoi';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isControversial].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is the subject of cultural, political, religious, or other controversy.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isControversial';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isInteractivePoi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available for end user interaction. Used in (ASX).tbAppearance.POI and (ASXi 3D).tbGeoRefId.IPoi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isInteractivePoi';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isInteractiveSearch].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available for end user search.  Used in (ASXi 3D).tbgeorefid.isearch.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isInteractiveSearch';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isMakkahPoi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available for the Makkah Pointer feature.  Used in (ASXi 3D).tbgeorefid.MakkahPOI.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isMakkahPoi';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isRliPoi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available for the Relative Location Indicator feature. Used in (ASXi 3D).tbGeoRefId.RliPoi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isRliPoi';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isShipWreck].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a shipwreck site.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isShipWreck';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isSnapshot].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available for the Snapshots feature in ASXi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isSnapshot';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isSummit].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a summit type (mount, mountain, peak).  Use isTerrainLand for mountain ranges.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isSummit';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isTerrainLand].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a topographic or land area feature (cape, island, mountain range, park, ...).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isTerrainLand';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isTerrainOcean].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a bathymetric feature.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isTerrainOcean';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isTimeZonePoi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available for the 3-D Time Zone feature.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isTimeZonePoi';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isWaterBody].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is a water body feature (bay, river, lake, ocean, sound, ...).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isWaterBody';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isWorldClockPoi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available for the World Clock feature. Used in (ASXi 3D).tbGeoRefId.WcPoi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isWorldClockPoi';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[isWGuide].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates if this place name is available for the World Guide feature in ASXi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'isWGuide';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[Priority].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Defines the display priority for this place name relative to other place names.  Values (high-low): 3-n.  Values 1-2 reserved for customer use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'Priority';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[AsxiPriority].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Defines the ASXi-specific display priority.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'AsxiPriority';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[MarkerId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Marker used to pin-point this place name. Used in (ASX).tbAppearance.MarkerId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'MarkerId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[AtlasMarkerId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Atlas marker used to pin-point this place name. Used in (ASX).tbAppearance.AtlasMarkerId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'AtlasMarkerId';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[MapStatsAppearance].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Configures which statistics to display on the map for this place name.  BIT values: 1 = distance to aircraft; 2 = elevation; 4 = population. Used in (ASXi 3.3).tbGeoRefId.LayerDisplay.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'MapStatsAppearance';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[PoiPanelStatsAppearance].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Configures which statistics to display in the POI Panel feature. Values: 1-5. Used in (ASX).tbSpelling.POIGroup.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'PoiPanelStatsAppearance';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[RliAppearance].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Configures the availability of this place name in the RLI feature. BIT values: 0 = exclude; 1 = closest city; 4 = user selectable; 5 = 1 and 4. Used in (ASXi PAC/THA, AS Mobile).tbgeorefid.POIType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'RliAppearance';


GO
PRINT N'Creating Extended Property [dbo].[tblGeoRef].[KeepNew].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Used in SystemAsx for the DB Merge process.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGeoRef', @level2type = N'COLUMN', @level2name = N'KeepNew';


GO
PRINT N'Creating Extended Property [dbo].[tblGlobalConfigurationMapping].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This table maps a configuration definition to the global configuration. It doesn’t map to each individual version of the global configuration, as that is handled via the tblConfigurations table. If the global configuration changes significantly (i.e. new products with new data sets are added to ACE), then a new record will be added to link the global configuration to the new configuration definition, and the record will be given a larger MappingIndex value to indicate that it should be used for all new configurations.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlobalConfigurationMapping';


GO
PRINT N'Creating Extended Property [dbo].[tblHistory].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This table keeps track of modifications on the configurable tables.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHistory';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[LanguageID].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Unique language identifier.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'LanguageID';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[Name].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Name of the language in English.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'Name';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[NativeName].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Localized name of the language.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'NativeName';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[ISLatinScript].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates whether this language is stored in the database using the Latin alphabet writing system.  0 = false; 1 = true.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'ISLatinScript';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[Tier].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Language grouping. Translations should be made available in all Tier 1 languages.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'Tier';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[2LetterID_4xxx].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '2-character language code used in 4xxx.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'2LetterID_4xxx';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[3LetterID_4xxx].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '3-character language code used in 4xxx.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'3LetterID_4xxx';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[2LetterID_ASXi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ISO 639-1 two-character language code used in ASXi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'2LetterID_ASXi';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[3LetterID_ASXi].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ISO 639-2 three-character language code used in ASXi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'3LetterID_ASXi';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[HorizontalScroll].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '0 = use default; 1 = right-to-left; 2 = left-to-right', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'HorizontalScroll';


GO
PRINT N'Creating Extended Property [dbo].[tblLanguages].[VerticalOrder].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '0 = use default; 1 = right-to-left; 2 = left-to-right', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblLanguages', @level2type = N'COLUMN', @level2name = N'VerticalOrder';


GO
PRINT N'Creating Extended Property [dbo].[tblMetroMapGeoRefs].[Priority].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Defines the display priority for this place name relative to other place names.  Values (high-low): 3-n.  Values 1-2 reserved for customer use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMetroMapGeoRefs', @level2type = N'COLUMN', @level2name = N'Priority';


GO
PRINT N'Creating Extended Property [dbo].[tblMetroMapGeoRefs].[MarkerId].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Marker used to pin-point this place name. Refers to tblAppearance.MarkerId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMetroMapGeoRefs', @level2type = N'COLUMN', @level2name = N'MarkerId';


GO
PRINT N'Creating Extended Property [dbo].[tblMetroMapGeoRefs].[AtlasMarkerID].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Atlas marker used to pin-point this place name. Refers to tblAppearance.AtlasMarkerId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMetroMapGeoRefs', @level2type = N'COLUMN', @level2name = N'AtlasMarkerID';


GO
PRINT N'Creating Extended Property [dbo].[tblOutputTypes].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This table defines the different output formats that can be created by the build process.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblOutputTypes';


GO
PRINT N'Creating Extended Property [dbo].[tblProductType].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This table specifies the unique configuration requirements for the different Airshow configuration formats. This generally maps to the various Airshow product iterations (e.g. ASXi4, ASXi3, AS4000). Each configuration definition will reference this table to determine which data sets are to be used for merges, as well as what data is displayed within the UX.  Note: The data sets (e.g. timezone, placenames) used for a particular product cannot be changed once it has been set. If a change is needed, then a new Product record needs to be defined. This is needed to prevent changes to locked configurations that referenced the previous product definition. WE SHOULD USE DATABASE TRIGGERS (UPDATE, DELETE) TO PREVENT CHANGES TO ANY RECORD THAT IS REFERENCED BY tblConfigurationReferences.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblProductType';


GO
PRINT N'Creating Extended Property [dbo].[tblTimeZoneStrip].[IdVer1].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Time zone strip identifier used in ASX (4XXX, 500, Venue, etc.) and pre-ASXi 4.0 configs.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblTimeZoneStrip', @level2type = N'COLUMN', @level2name = N'IdVer1';


GO
PRINT N'Creating Extended Property [dbo].[tblTimeZoneStrip].[IdVer2].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Time zone strip identifier used in ASXi 4.x configs.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblTimeZoneStrip', @level2type = N'COLUMN', @level2name = N'IdVer2';


GO
PRINT N'Update complete.';


GO
