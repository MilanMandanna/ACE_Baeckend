CREATE TABLE [cust].[tblNewsMap]
(
	[ConfigurationID] int NULL,
	[NewsID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[PreviousNewsID] int NULL,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblNewsMap] ADD CONSTRAINT [FK_tblNewsMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblNewsMap] ADD CONSTRAINT [FK_tblNewsMap_tblNews]
	FOREIGN KEY ([NewsID]) REFERENCES [cust].[tblNews] ([NewsID]) ON DELETE No Action ON UPDATE No Action