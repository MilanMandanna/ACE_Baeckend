CREATE TABLE [dbo].[tblPlatforms]
(
	[PlatformID] int NOT NULL,
	[Name] nvarchar(100) NULL,
	[Description] nvarchar(255) NULL,
	[InstallationTypeID] uniqueidentifier NULL
)
GO
ALTER TABLE [dbo].[tblPlatforms] ADD CONSTRAINT [FK_tblPlatforms_InstallationTypes]
	FOREIGN KEY ([InstallationTypeID]) REFERENCES [dbo].[InstallationTypes] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblPlatforms] 
 ADD CONSTRAINT [PK_tblPlatforms]
	PRIMARY KEY CLUSTERED ([PlatformID] ASC)