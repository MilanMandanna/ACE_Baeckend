CREATE TABLE [dbo].[tblTaskStatus]
(
	[ID] int NOT NULL,
	[Name] nvarchar(50) NULL,
	[Description] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblTaskStatus] 
 ADD CONSTRAINT [PK_TaskStatus]
	PRIMARY KEY CLUSTERED ([ID] ASC)