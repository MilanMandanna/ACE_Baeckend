CREATE TABLE [dbo].[tblCityPopulation]
(
	[CityPopulationID] int NOT NULL IDENTITY (1, 1),
	[GeoRefID] int NULL,
	[UnCodeID] int NULL,
	[Population] int NULL,
	[TimeStampModified] timestamp NOT NULL,
	[SourceDate] datetime NULL
)
GO
ALTER TABLE [dbo].[tblCityPopulation] 
 ADD CONSTRAINT [PK_tblCityPopulation]
	PRIMARY KEY CLUSTERED ([CityPopulationID] ASC)