CREATE TABLE [cust].[tblWorldTimeZonePlaceNames]
(
	[PlaceNameID] int NOT NULL IDENTITY (1, 1),
	[PlaceNames] xml NULL
)
GO
ALTER TABLE [cust].[tblWorldTimeZonePlaceNames] 
 ADD CONSTRAINT [PK_tblWorldTimeZonePlaceNames]
	PRIMARY KEY CLUSTERED ([PlaceNameID] ASC)