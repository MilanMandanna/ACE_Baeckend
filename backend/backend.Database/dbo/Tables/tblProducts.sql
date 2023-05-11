CREATE TABLE [dbo].[tblProducts]
(
	[ProductID] int NOT NULL,
	[Name] nvarchar(255) NULL,
	[Description] nvarchar(255) NULL,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblProducts] 
 ADD CONSTRAINT [PK_tblProducts]
	PRIMARY KEY CLUSTERED ([ProductID] ASC)