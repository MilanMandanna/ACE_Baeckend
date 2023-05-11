CREATE TABLE [dbo].[tblFleets]
(
	[FleetID] int NOT NULL,
	[Name] nvarchar(255) NULL,
	[Description] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblFleets] 
 ADD CONSTRAINT [PK_tblFleets]
	PRIMARY KEY CLUSTERED ([FleetID] ASC)