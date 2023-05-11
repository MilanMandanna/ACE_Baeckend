CREATE TABLE [cust].[tblScriptDefsMap]
(
	[ScriptDefID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousScriptDefID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblScriptDefsMap] ADD CONSTRAINT [FK_tblScriptDefsMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblScriptDefsMap] ADD CONSTRAINT [FK_tblScriptDefsMap_tblScriptDefs]
	FOREIGN KEY ([ScriptDefID]) REFERENCES [cust].[tblScriptDefs] ([ScriptDefID]) ON DELETE Cascade ON UPDATE No Action