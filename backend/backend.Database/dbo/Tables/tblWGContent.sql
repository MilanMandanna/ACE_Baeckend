CREATE TABLE [dbo].[tblWGContent]
(
	[WGContentID] int NOT NULL IDENTITY (1, 1),
	[GeoRefID] int NULL,
	[TypeID] int NULL,
	[ImageID] int NULL,
	[TextID] int NULL
)
GO
ALTER TABLE [dbo].[tblWGContent] 
 ADD CONSTRAINT [PK_tblWGContent]
	PRIMARY KEY CLUSTERED ([WGContentID] ASC)