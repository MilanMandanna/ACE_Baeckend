CREATE TABLE [dbo].[tblArea]
(
	[AreaID] int NOT NULL IDENTITY (1, 1),
	[GeoRefID] int NULL,
	[Area] int NULL,
	[LastModifiedDate] timestamp NOT NULL,
	[DataSourceID] int NULL
)
GO
ALTER TABLE [dbo].[tblArea] 
 ADD CONSTRAINT [PK_tblArea]
	PRIMARY KEY CLUSTERED ([AreaID] ASC)