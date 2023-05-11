CREATE TABLE [cust].[tblMenuMap]
(
	[ConfigurationID] int NULL,
	[MenuID] int NULL,
	[PreviousMenuID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblMenuMap] ADD CONSTRAINT [FK_tblMenuMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblMenuMap] ADD CONSTRAINT [FK_tblMenuMap_tblMenu]
	FOREIGN KEY ([MenuID]) REFERENCES [cust].[tblMenu] ([MenuID]) ON DELETE Cascade ON UPDATE No Action