CREATE TABLE [dbo].[tblMapInsetsMap]
(
	[ConfigurationID] int NULL,
	[MapInsetsID] int NULL,
	[PreviousMapInsetsID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblMapInsetsMap] ADD CONSTRAINT [FK_tblMapInsetsMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblMapInsetsMap] ADD CONSTRAINT [FK_tblMapInsetsMap_tblMapInsets]
	FOREIGN KEY ([MapInsetsID]) REFERENCES [dbo].[tblMapInsets] ([MapInsetsID]) ON DELETE Cascade ON UPDATE No Action