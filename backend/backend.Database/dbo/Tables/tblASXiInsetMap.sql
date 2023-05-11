CREATE TABLE [dbo].[tblASXiInsetMap]
(
	[ConfigurationID] int NULL,
	[ASXiInsetID] int NULL,
	[PreviousASXiInsetID] int NULL,
	[IsDeleted] bit NULL,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblASXiInsetMap] ADD CONSTRAINT [FK_tblASXiInsetMap_tblASXiInset]
	FOREIGN KEY ([ASXiInsetID]) REFERENCES [dbo].[tblASXiInset] ([ASXiInsetID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblASXiInsetMap] ADD CONSTRAINT [FK_tblASXiInsetMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action