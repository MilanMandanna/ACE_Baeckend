CREATE TABLE [dbo].[tblElevation]
(
	[ID] int NOT NULL IDENTITY (1, 1),
	[GeoRefID] int NULL,
	[Elevation] int NULL,
	[DatasourceID] int NULL
)
GO
ALTER TABLE [dbo].[tblElevation] 
 ADD CONSTRAINT [PK_tblElevation]
	PRIMARY KEY CLUSTERED ([ID] ASC)