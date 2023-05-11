CREATE TABLE [cust].[tblWorldTimeZonePlaceNamesMap]
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
ALTER TABLE [cust].[tblWorldTimeZonePlaceNamesMap] ADD CONSTRAINT [FK_tblWorldTimeZonePlaceNamesMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblWorldTimeZonePlaceNamesMap] ADD CONSTRAINT [FK_tblWorldTimeZonePlaceNamesMap_tblWorldTimeZonePlaceNames]
	FOREIGN KEY ([PlaceNameID]) REFERENCES [cust].[tblWorldTimeZonePlaceNames] ([PlaceNameID]) ON DELETE Cascade ON UPDATE No Action