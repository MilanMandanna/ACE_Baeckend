CREATE TABLE [dbo].[tblAircraftConfigurationMapping]
(
	[ConfigurationDefinitionID] int NULL,
	[MappingIndex] int NULL,
	[AircraftID] uniqueidentifier NULL
)
GO
ALTER TABLE [dbo].[tblAircraftConfigurationMapping] ADD CONSTRAINT [FK_tblAircraftConfigurationMapping_tblConfigurationDefinitions]
	FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE Set Null ON UPDATE No Action
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'This table keeps track of the logical relationships between configurations. For example, there can be multiple versions of a configuration for an aircraft, but they are all versions of the same "configuration". Each configuration reference points to a parent configuration that it inherits values from during the merge function. Each configuration reference also specifies a aircraft that it is a configuration for.   This tells ACE which data is applicable for this configuration and what configuration file outputs should be generated during the build process.  A new row is added to this table whenever we need a new configuration for a new entity in ACE, such as a new aircraft, a new fleet, a new product, or a new platform.   We also add a new row if something fundamental changes about the Airshow configuration for one of those entities, such as when an aircraft changes which Airshow product is installed on that aircraft (i.e. a cabin upgrade that results in a change from AS4000 to ASXi4). Please see the tblAircraftConfigurationMapping table for an example of how this works.', 'SCHEMA', 'dbo', 'table', 'tblAircraftConfigurationMapping'