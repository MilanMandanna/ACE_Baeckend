CREATE TABLE [cust].[tblRLIMap]
(
	[RLIID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousRLIID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblRLIMap] ADD CONSTRAINT [FK_tblRLIMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblRLIMap] ADD CONSTRAINT [FK_tblRLIMap_tblRli]
	FOREIGN KEY ([RLIID]) REFERENCES [cust].[tblRli] ([RLIID]) ON DELETE Cascade ON UPDATE No Action