CREATE TABLE [dbo].[tblHistory]
(
	[HistoryID] bigint NOT NULL IDENTITY (1, 1),
	[RowID] bigint NOT NULL,
	[ParentRowID] bigint NULL,
	[Notes] nvarchar(255) NULL,
	[TableName] nvarchar(100) NOT NULL,
	[Timestamp] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NOT NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblHistory] 
 ADD CONSTRAINT [PK_tblHistory]
	PRIMARY KEY CLUSTERED ([HistoryID] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'This table keeps track of modifications on the configurable tables.', 'SCHEMA', 'dbo', 'table', 'tblHistory'