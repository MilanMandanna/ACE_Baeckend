CREATE TABLE [dbo].[tblConfigurationTypes]
(
	[ConfigurationTypeID] int NOT NULL,
	[Name] nvarchar(50) NULL,
	[UsesTimezone] tinyint NULL,
	[UsesPlacenames] bit NULL
)
GO
ALTER TABLE [dbo].[tblConfigurationTypes] 
 ADD CONSTRAINT [PK_tblConfigurationTypes]
	PRIMARY KEY CLUSTERED ([ConfigurationTypeID] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'This table specifies the unique configuration requirements for the different Airshow configuration formats. This generally maps to the various Airshow product iterations (e.g. ASXi4, ASXi3, AS4000). Each configuration definition will reference this table to determine which data sets are to be used for merges, as well as what data is displayed within the UX.  Note: The data sets (e.g. timezone, placenames) used for a particular product cannot be changed once it has been set. If a change is needed, then a new Product record needs to be defined. This is needed to prevent changes to locked configurations that referenced the previous product definition. WE SHOULD USE DATABASE TRIGGERS (UPDATE, DELETE) TO PREVENT CHANGES TO ANY RECORD THAT IS REFERENCED BY tblConfigurationReferences.', 'SCHEMA', 'dbo', 'table', 'tblConfigurationTypes'