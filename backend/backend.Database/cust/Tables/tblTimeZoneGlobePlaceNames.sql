CREATE TABLE [cust].[tblTimeZoneGlobePlaceNames]
(
	[PlaceNameID] int NOT NULL IDENTITY (1, 1),
	[PlaceNames] xml NULL
)
GO
ALTER TABLE [cust].[tblTimeZoneGlobePlaceNames] 
 ADD CONSTRAINT [PK_tblTimeZoneGlobePlaceNames]
	PRIMARY KEY CLUSTERED ([PlaceNameID] ASC)