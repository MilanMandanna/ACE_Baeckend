CREATE TABLE [cust].[tblModeDefsMap]
(
	[ModeDefID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousModeDefID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL,
)
GO
ALTER TABLE [cust].[tblModeDefsMap] ADD CONSTRAINT [FK_tblModeDefsMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblModeDefsMap] ADD CONSTRAINT [FK_tblModeDefsMap_tblModeDefs]
	FOREIGN KEY ([ModeDefID]) REFERENCES [cust].[tblModeDefs] ([ModeDefID]) ON DELETE Cascade ON UPDATE No Action