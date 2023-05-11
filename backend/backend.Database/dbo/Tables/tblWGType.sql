CREATE TABLE [dbo].[tblWGType]
(
	[WGTypeID] int NOT NULL IDENTITY (1, 1),
	[TypeID] int NULL,
	[Description] nvarchar(255) NULL,
	[Layout] int NULL,
	[ImageWidth] int NULL,
	[ImageHeight] int NULL
)
GO
ALTER TABLE [dbo].[tblWGType] 
 ADD CONSTRAINT [PK_tbWGType]
	PRIMARY KEY CLUSTERED ([WGTypeID] ASC)