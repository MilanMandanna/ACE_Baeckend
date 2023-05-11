CREATE TABLE [cust].[tblMiqatMap]
(
	[ConfigurationID] int NULL,
	[MiqatID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[PreviousMiqatID] int NULL,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblMiqatMap] ADD CONSTRAINT [FK_tblMiqatMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblMiqatMap] ADD CONSTRAINT [FK_tblMiqatMap_tblMiqat]
	FOREIGN KEY ([MiqatID]) REFERENCES [cust].[tblMiqat] ([MiqatID]) ON DELETE Cascade ON UPDATE No Action