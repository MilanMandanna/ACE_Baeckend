CREATE TABLE [cust].[tblTimeZoneGlobePlaceNamesMap]
(
	[PlaceNameID] int NOT NULL,
	[ConfigurationID] int NULL,
	[PreviousPlaceNameID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblTimeZoneGlobePlaceNamesMap] ADD CONSTRAINT [FK_tblTimeZoneGlobePlaceNamesMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblTimeZoneGlobePlaceNamesMap] ADD CONSTRAINT [FK_tblTimeZoneGlobePlaceNamesMap_tblTimeZoneGlobePlaceNames]
	FOREIGN KEY ([PlaceNameID]) REFERENCES [cust].[tblTimeZoneGlobePlaceNames] ([PlaceNameID]) ON DELETE Cascade ON UPDATE No Action