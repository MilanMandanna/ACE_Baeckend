CREATE TABLE [dbo].[tblIpadConfig]
(
	[IpadConfigID] int NOT NULL IDENTITY (1, 1),
	[IpadConfig] xml NULL
)
GO
ALTER TABLE [dbo].[tblIpadConfig] 
 ADD CONSTRAINT [PK_tblIpadConfig]
	PRIMARY KEY CLUSTERED ([IpadConfigID] ASC)