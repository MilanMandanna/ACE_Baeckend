CREATE TABLE [dbo].[tblConfigurationComponents]
(
	[ConfigurationComponentID] int NOT NULL,
	[Path] nvarchar(500) NULL,
	[ConfigurationComponentTypeID] int NULL,
	[Name] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblConfigurationComponents] ADD CONSTRAINT [FK_tblConfigurationComponents_tblConfigurationComponentType]
	FOREIGN KEY ([ConfigurationComponentTypeID]) REFERENCES [dbo].[tblConfigurationComponentType] ([ConfigurationComponentTypeID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblConfigurationComponents] 
 ADD CONSTRAINT [PK_tblConfigurationComponents]
	PRIMARY KEY CLUSTERED ([ConfigurationComponentID] ASC)