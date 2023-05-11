CREATE TABLE [dbo].[tblAsxiProfileMap]
(
	[ConfigurationID] int NULL,
	[AsxiProfileID] int NULL,
	[PreviousAsxiProfileID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblAsxiProfileMap] ADD CONSTRAINT [FK_tblAsxiProfileMap_tblAsxiProfile]
	FOREIGN KEY ([AsxiProfileID]) REFERENCES [dbo].[tblAsxiProfile] ([AsxiProfileID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblAsxiProfileMap] ADD CONSTRAINT [FK_tblAsxiProfileMap_tblConfigurations_copy]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action