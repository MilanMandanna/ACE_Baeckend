CREATE TABLE [cust].[tblWorldMapCities]
(
	[WorldMapCityID] int NOT NULL IDENTITY (1, 1),
	[WorldMapCities] xml NULL
)
GO
ALTER TABLE [cust].[tblWorldMapCities] 
 ADD CONSTRAINT [PK_WorldClockCities_copy]
	PRIMARY KEY CLUSTERED ([WorldMapCityID] ASC)