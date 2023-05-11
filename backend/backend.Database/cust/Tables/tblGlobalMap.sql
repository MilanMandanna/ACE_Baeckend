CREATE TABLE [cust].[tblGlobalMap]
(
	[ConfigurationID] int NULL,
	[CustomID] int NULL,
	[PreviousCustomID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(250) NULL,
	[Action] nvarchar(250) NULL
)
GO
ALTER TABLE [cust].[tblGlobalMap] ADD CONSTRAINT [FK_tblCustomMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblGlobalMap] ADD CONSTRAINT [FK_tblCustomMap_tblCustom]
	FOREIGN KEY ([CustomID]) REFERENCES [cust].[tblGlobal] ([CustomID]) ON DELETE Cascade ON UPDATE No Action