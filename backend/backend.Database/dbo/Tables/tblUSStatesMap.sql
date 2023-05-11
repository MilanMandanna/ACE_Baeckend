CREATE TABLE [dbo].[tblUSStatesMap]
(
	[ConfigurationID] int NOT NULL,
	[StateID] nvarchar(2) NULL,
	[PreviousStateID] int NULL DEFAULT -1,
	[isDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblUSStatesMap] ADD CONSTRAINT [FK_tblUSStatesMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblUSStatesMap] ADD CONSTRAINT [FK_tblUSStatesMap_tblUSStates]
	FOREIGN KEY ([StateID]) REFERENCES [dbo].[tblUSStates] ([StateID]) ON DELETE Cascade ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblUSStatesMap_tblConfigurations] 
 ON [dbo].[tblUSStatesMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblUSStatesMap_tblUSStates] 
 ON [dbo].[tblUSStatesMap] ([StateID] ASC)