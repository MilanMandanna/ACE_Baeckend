CREATE TABLE [cust].[tblConfigVersionMap]
(
	[ConfigVersionID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousConfigVersionID] int NULL,
	[isDeleted] bit NULL,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblConfigVersionMap] ADD CONSTRAINT [FK_tblConfigVersionMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [cust].[tblConfigVersionMap] ADD CONSTRAINT [FK_tblConfigVersionMap_tblConfigVersion]
	FOREIGN KEY ([ConfigVersionID]) REFERENCES [cust].[tblConfigVersion] ([ConfigVersionID]) ON DELETE No Action ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigVersionMap_tblConfigurations] 
 ON [cust].[tblConfigVersionMap] ([ConfigurationID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblConfigVersionMap_tblConfigVersion] 
 ON [cust].[tblConfigVersionMap] ([ConfigVersionID] ASC)