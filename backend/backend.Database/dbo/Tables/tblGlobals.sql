CREATE TABLE [dbo].[tblGlobals]
(
	[GlobalID] int NOT NULL,
	[Name] nvarchar(255) NULL,
	[Description] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblGlobals] 
 ADD CONSTRAINT [PK_tblGlobals]
	PRIMARY KEY CLUSTERED ([GlobalID] ASC)