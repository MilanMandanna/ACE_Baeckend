CREATE TABLE [cust].[tblTriggerMap]
(
	[TriggerID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousTriggerID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblTriggerMap] ADD CONSTRAINT [FK_tblTriggerMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblTriggerMap] ADD CONSTRAINT [FK_tblTriggerMap_tblTrigger]
	FOREIGN KEY ([TriggerID]) REFERENCES [cust].[tblTrigger] ([TriggerID]) ON DELETE No Action ON UPDATE No Action