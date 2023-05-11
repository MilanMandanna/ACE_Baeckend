CREATE TABLE [dbo].[tblTasks]
(
	[ID] uniqueidentifier NOT NULL,
	[TaskTypeID] uniqueidentifier NULL,
	[StartedByUserID] uniqueidentifier NULL,
	[TaskStatusID] int NULL,
	[DateStarted] datetime NULL,
	[DateLastUpdated] datetime NULL,
	[PercentageComplete] float NULL,
	[DetailedStatus] nvarchar(50) NULL,
	[AzureBuildID] int NULL,
	[AircraftID] uniqueidentifier NULL,
	[ConfigurationDefinitionID] int NULL,
	[ConfigurationID] int NULL
    [ErrorLog] NVARCHAR (MAX)   NULL,
    [TaskDataJSON] NVARCHAR (MAX)   NULL,
)
GO
ALTER TABLE [dbo].[tblTasks] ADD CONSTRAINT [FK_tblTasks_TaskStatus]
	FOREIGN KEY ([TaskStatusID]) REFERENCES [dbo].[tblTaskStatus] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblTasks] ADD CONSTRAINT [FK_tblTasks_TaskType]
	FOREIGN KEY ([TaskTypeID]) REFERENCES [dbo].[tblTaskType] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblTasks] 
 ADD CONSTRAINT [PK_tblTasks]
	PRIMARY KEY CLUSTERED ([ID] ASC)