CREATE TABLE [dbo].[tblCityPopulationMap]
(
	[ConfigurationID] int NULL,
	[CityPopulationID] int NULL,
	[PreviousCityPopulationID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblCityPopulationMap] ADD CONSTRAINT [FK_tblCityPopulationMap_tblCityPopulation]
	FOREIGN KEY ([CityPopulationID]) REFERENCES [dbo].[tblCityPopulation] ([CityPopulationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblCityPopulationMap] ADD CONSTRAINT [FK_tblCityPopulationMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblCityPopulationMap_tblCityPopulation] 
 ON [dbo].[tblCityPopulationMap] ([CityPopulationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblCityPopulationMap_tblConfigurations] 
 ON [dbo].[tblCityPopulationMap] ([ConfigurationID] ASC)