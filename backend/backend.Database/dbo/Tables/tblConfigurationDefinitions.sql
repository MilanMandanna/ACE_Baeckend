CREATE TABLE [dbo].[tblConfigurationDefinitions]
(
	[ConfigurationDefinitionID] int NOT NULL,
	[ConfigurationDefinitionParentID] int NULL,
	[ConfigurationTypeID] int NULL,
	[OutputTypeID] int NULL,
	[Active] bit NULL,
	[AutoLock] int NULL,
	[AutoDeploy] int NULL,
	[FeatureSetID] int NULL, 
    	[AutoMerge] INT NULL
)
GO

GO
ALTER TABLE [dbo].[tblConfigurationDefinitions] ADD CONSTRAINT [FK_tblConfigurationDefinitions_tblConfigurationTypes]
	FOREIGN KEY ([ConfigurationTypeID]) REFERENCES [dbo].[tblConfigurationTypes] ([ConfigurationTypeID]) ON DELETE Set Null ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblConfigurationDefinitions] ADD CONSTRAINT [FK_tblConfigurationDefinitions_tblOutputTypes]
	FOREIGN KEY ([OutputTypeID]) REFERENCES [dbo].[tblOutputTypes] ([OutputTypeID]) ON DELETE Set Null ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblConfigurationDefinitions] 
 ADD CONSTRAINT [PK_tblConfigurationDefinitions]
	PRIMARY KEY CLUSTERED ([ConfigurationDefinitionID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigurationDefinitions_tblFeatureSet] 
 ON [dbo].[tblConfigurationDefinitions] ([FeatureSetID] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'This table defines each configuration and keeps track of the hierarchical relationship between configurations by recording which configuration it inherits from. The individual versions of a particular configuration are recorded elsewhere, in the tblConfigurations table. For example, there can be multiple versions of a configuration for an aircraft, but they are all versions of the same "configuration" defined in this table. Each configuration definition points to a parent configuration that it inherits values from during the merge function. Each configuration definition also specifies a product that it is a configuration for. This tells ACE which data is applicable for this configuration and what outputs should be generated during the build process. A new row is added to this table whenever we need a new configuration for a new entity in ACE, such as a new aircraft, a new fleet, a new product, or a new platform. We also add a new row if something fundamental changes about the Airshow configuration for one of those entities, such as when an aircraft changes which Airshow product is installed on that aircraft (i.e. a cabin upgrade that results in a change from AS4000 to ASXi4). Please see the tblAircraftConfigurationMapping table for an example of how this works.', 'SCHEMA', 'dbo', 'table', 'tblConfigurationDefinitions'