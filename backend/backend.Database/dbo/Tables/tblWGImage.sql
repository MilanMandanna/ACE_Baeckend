CREATE TABLE [dbo].[tblWGImage]
(
	[ID] int NOT NULL IDENTITY (1, 1),
	[ImageID] int NOT NULL,
	[FileName] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblWGImage] 
 ADD CONSTRAINT [PK_tblWGImage]
	PRIMARY KEY CLUSTERED ([ID] ASC)