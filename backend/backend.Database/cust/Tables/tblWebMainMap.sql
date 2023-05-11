CREATE TABLE [cust].[tblWebMainMap]
(
	[ConfigurationID] int NULL,
	[WebMainID] int NULL,
	[PreviousWebMainID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblWebMainMap] ADD CONSTRAINT [FK_tblInfoItemsMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblWebMainMap] ADD CONSTRAINT [FK_tblWebMainMap_tblWebMain]
	FOREIGN KEY ([WebMainID]) REFERENCES [cust].[tblWebMain] ([WebMainID]) ON DELETE Cascade ON UPDATE No Action