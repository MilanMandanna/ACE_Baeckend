CREATE TABLE [dbo].[tblIpadConfigMap]
(
	[ConfigurationID] int NULL,
	[IpadConfigID] int NULL,
	[PreviousIpadConfigID] int NULL,
	[IsDeleted] bit NULL,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblIpadConfigMap] ADD CONSTRAINT [FK_tblIpadConfigMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblIpadConfigMap] ADD CONSTRAINT [FK_tblIpadConfigMap_tblIpadConfig]
	FOREIGN KEY ([IpadConfigID]) REFERENCES [dbo].[tblIpadConfig] ([IpadConfigID]) ON DELETE Cascade ON UPDATE No Action