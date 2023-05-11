CREATE TABLE [dbo].[tblConfigurationComponentType]
(
	[ConfigurationComponentTypeID] int NOT NULL,
	[Name] nvarchar(50) NULL,
	[Description] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblConfigurationComponentType] 
 ADD CONSTRAINT [PK_tblConfigurationComponentType]
	PRIMARY KEY CLUSTERED ([ConfigurationComponentTypeID] ASC)