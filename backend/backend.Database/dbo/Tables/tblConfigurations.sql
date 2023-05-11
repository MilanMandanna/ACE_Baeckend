CREATE TABLE [dbo].[tblConfigurations]
(
	[ConfigurationID] int NOT NULL,
	[ConfigurationDefinitionID] int NULL,
	[Version] int NULL,
	[Locked] bit NULL,
	[Description] nvarchar(255) NULL,
	[TimestampModified] timestamp NOT NULL,
	LockDate datetimeoffset(7) NULL
)
GO
ALTER TABLE [dbo].[tblConfigurations] ADD CONSTRAINT [FK_tblConfigurations_tblConfigurationDefinitions]
	FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE Set Null ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblConfigurations] 
 ADD CONSTRAINT [PK_tblConfigurationReferences]
	PRIMARY KEY CLUSTERED ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigurationReferences_tblConfigurationReferences] 
 ON [dbo].[tblConfigurations] ([ConfigurationDefinitionID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigurationReferences_tblProducts] 
 ON [dbo].[tblConfigurations] ([Version] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'This table defines each version of a configuration.', 'SCHEMA', 'dbo', 'table', 'tblConfigurations'

