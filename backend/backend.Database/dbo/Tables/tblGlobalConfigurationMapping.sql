CREATE TABLE [dbo].[tblGlobalConfigurationMapping]
(
	[GlobalConfigurationMappingID] int NOT NULL,
	[GlobalID] int NULL,
	[ConfigurationDefinitionID] int NULL,
	[MappingIndex] int NULL
)
GO
ALTER TABLE [dbo].[tblGlobalConfigurationMapping] ADD CONSTRAINT [FK_tblGlobalConfigurationMapping_tblConfigurationDefinitions]
	FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE Set Null ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblGlobalConfigurationMapping] ADD CONSTRAINT [FK_tblGlobalConfigurationMapping_tblGlobals]
	FOREIGN KEY ([GlobalID]) REFERENCES [dbo].[tblGlobals] ([GlobalID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblGlobalConfigurationMapping] 
 ADD CONSTRAINT [PK_tblGlobalConfigurationMapping]
	PRIMARY KEY CLUSTERED ([GlobalConfigurationMappingID] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'This table maps a configuration definition to the global configuration. It doesn’t map to each individual version of the global configuration, as that is handled via the tblConfigurations table. If the global configuration changes significantly (i.e. new products with new data sets are added to ACE), then a new record will be added to link the global configuration to the new configuration definition, and the record will be given a larger MappingIndex value to indicate that it should be used for all new configurations.', 'SCHEMA', 'dbo', 'table', 'tblGlobalConfigurationMapping'