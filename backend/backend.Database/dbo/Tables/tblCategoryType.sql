CREATE TABLE [dbo].[tblCategoryType]
(
	[CategoryTypeID] int NOT NULL IDENTITY (1, 1),
	[GeoRefCategoryTypeID] int NULL,
	[GeoRefCategoryTypeID_ASXIAndroid] int NULL DEFAULT NULL,
	[Description] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblCategoryType] 
 ADD CONSTRAINT [PK_tblCategoryType]
	PRIMARY KEY CLUSTERED ([CategoryTypeID] ASC)