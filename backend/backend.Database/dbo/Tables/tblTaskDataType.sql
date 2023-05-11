CREATE TABLE [dbo].[tblTaskDataType]
(
	[ID] uniqueidentifier NOT NULL,
	[Name] nvarchar(50) NULL,
	[Description] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblTaskDataType] 
 ADD CONSTRAINT [PK_TaskDataType]
	PRIMARY KEY CLUSTERED ([ID] ASC)