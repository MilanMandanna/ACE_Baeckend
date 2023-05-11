CREATE TABLE [dbo].[tblTaskType]
(
	[ID] uniqueidentifier NOT NULL,
	[Name] nvarchar(50) NULL,
	[Description] nvarchar(50) NULL,
	[AzureDefinitionID] int NULL
)
GO
ALTER TABLE [dbo].[tblTaskType] 
 ADD CONSTRAINT [PK_TaskType]
	PRIMARY KEY CLUSTERED ([ID] ASC)