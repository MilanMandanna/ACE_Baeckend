CREATE TABLE [cust].[tblMakkahMap]
(
	[MakkahID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousMakkahID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblMakkahMap] ADD CONSTRAINT [FK_tblMakkahMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblMakkahMap] ADD CONSTRAINT [FK_tblMakkahMap_tblMakkah]
	FOREIGN KEY ([MakkahID]) REFERENCES [cust].[tblMakkah] ([MakkahID]) ON DELETE Cascade ON UPDATE No Action