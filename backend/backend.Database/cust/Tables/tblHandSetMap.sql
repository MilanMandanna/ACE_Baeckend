CREATE TABLE [cust].[tblHandSetMap]
(
	[HandSetID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousHandSetID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblHandSetMap] ADD CONSTRAINT [FK_tblHandSetMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblHandSetMap] ADD CONSTRAINT [FK_tblHandSetMap_tblHandSet]
	FOREIGN KEY ([HandSetID]) REFERENCES [cust].[tblHandSet] ([HandSetID]) ON DELETE Cascade ON UPDATE No Action