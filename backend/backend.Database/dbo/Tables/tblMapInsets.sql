CREATE TABLE [dbo].[tblMapInsets]
(
	[MapInsetsID] int NOT NULL IDENTITY (1, 1),
	[MapInsets] xml NULL
)
GO
ALTER TABLE [dbo].[tblMapInsets] 
 ADD CONSTRAINT [PK_tblMapInsets]
	PRIMARY KEY CLUSTERED ([MapInsetsID] ASC)