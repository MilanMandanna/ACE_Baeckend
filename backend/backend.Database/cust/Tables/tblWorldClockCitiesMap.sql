CREATE TABLE [cust].[tblWorldClockCitiesMap]
(
	[WorldClockCityID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousWorldClockCityID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblWorldClockCitiesMap] ADD CONSTRAINT [FK_tblWorldClockCityMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblWorldClockCitiesMap] ADD CONSTRAINT [FK_tblWorldClockCityMap_WorldClockCities]
	FOREIGN KEY ([WorldClockCityID]) REFERENCES [cust].[tblWorldClockCities] ([WorldClockCityID]) ON DELETE Cascade ON UPDATE No Action