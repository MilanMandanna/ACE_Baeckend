CREATE TABLE [dbo].[tblTaskData]
(
	[ID] uniqueidentifier NOT NULL,
	[TaskID] uniqueidentifier NULL,
	[TaskDataTypeID] uniqueidentifier NULL,
	[StringData] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblTaskData] ADD CONSTRAINT [FK_TaskData _TaskDataType]
	FOREIGN KEY ([TaskDataTypeID]) REFERENCES [dbo].[tblTaskDataType] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblTaskData] ADD CONSTRAINT [FK_TaskData _tblTasks]
	FOREIGN KEY ([TaskID]) REFERENCES [dbo].[tblTasks] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblTaskData] 
 ADD CONSTRAINT [PK_TaskData]
	PRIMARY KEY CLUSTERED ([ID] ASC)