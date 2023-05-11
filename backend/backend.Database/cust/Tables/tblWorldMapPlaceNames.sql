CREATE TABLE [cust].[tblWorldMapPlaceNames]
(
	[PlaceNameID] int NOT NULL IDENTITY (1, 1),
	[PlaceNames] xml NULL
)
GO
ALTER TABLE [cust].[tblWorldMapPlaceNames] 
 ADD CONSTRAINT [PK_tblWorldMapPlaceNames]
	PRIMARY KEY CLUSTERED ([PlaceNameID] ASC)