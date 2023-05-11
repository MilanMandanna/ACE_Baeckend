CREATE TABLE [cust].[tblWorldMapCitiesMap]
(
	[WorldMapCityID] int NOT NULL,
	[ConfigurationID] int NOT NULL,
	[PreviousWorldMapCityID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblWorldMapCitiesMap] ADD CONSTRAINT [FK_tblWorldMapCitiesMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblWorldMapCitiesMap] ADD CONSTRAINT [FK_tblWorldMapCitiesMap_tblWorldMapCities]
	FOREIGN KEY ([WorldMapCityID]) REFERENCES [cust].[tblWorldMapCities] ([WorldMapCityID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblWorldMapCitiesMap] 
 ADD CONSTRAINT [PK_tblWorldMapCitiesMap]
	PRIMARY KEY CLUSTERED ([WorldMapCityID] ASC,[ConfigurationID] ASC)