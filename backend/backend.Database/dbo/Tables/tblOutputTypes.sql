CREATE TABLE [dbo].[tblOutputTypes]
(
	[OutputTypeID] int NOT NULL,
	[OutputTypeName] nvarchar(100) NULL
)
GO
ALTER TABLE [dbo].[tblOutputTypes] 
 ADD CONSTRAINT [PK_tblOutputTypes]
	PRIMARY KEY CLUSTERED ([OutputTypeID] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'This table defines the different output formats that can be created by the build process.', 'SCHEMA', 'dbo', 'table', 'tblOutputTypes'