CREATE TABLE [dbo].[tblFleetConfigurationMapping]
(
	[FleetID] int NULL,
	[ConfigurationDefinitionID] int NULL
)
GO
ALTER TABLE [dbo].[tblFleetConfigurationMapping] ADD CONSTRAINT [FK_tblFleetConfigurationMapping_tblConfigurationDefinitions]
	FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE Set Null ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblFleetConfigurationMapping] ADD CONSTRAINT [FK_tblFleetConfigurationMapping_tblFleets]
	FOREIGN KEY ([FleetID]) REFERENCES [dbo].[tblFleets] ([FleetID]) ON DELETE Cascade ON UPDATE No Action