CREATE TABLE [dbo].[InstallationTypes]
(
	[ID] uniqueidentifier NOT NULL,
	[InstallationTypeValue] nvarchar(50) NULL,
	[SupportedConnectionType] nvarchar(50) NULL,
	[StageClientTypeId] uniqueidentifier NULL,
	[MediaStorageSize] bigint NULL
)
GO
ALTER TABLE [dbo].[InstallationTypes] 
 ADD CONSTRAINT [PK_InstallationTypes]
	PRIMARY KEY CLUSTERED ([ID] ASC)