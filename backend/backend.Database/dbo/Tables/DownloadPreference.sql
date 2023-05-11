CREATE TABLE [dbo].[DownloadPreference]
(
	[Id] uniqueidentifier NOT NULL,
	[AssetType] int NOT NULL,
	[Name] nvarchar(max) NULL,
	[Title] nvarchar(max) NULL
)
GO
ALTER TABLE [dbo].[DownloadPreference] 
 ADD CONSTRAINT [PK_dbo.DownloadPreference]
	PRIMARY KEY CLUSTERED ([Id] ASC)