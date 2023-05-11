CREATE TABLE [dbo].[tblAreaMap]
(
	[ConfigurationID] int NULL,
	[AreaID] int NULL,
	[PreviousAreaID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblAreaMap] ADD CONSTRAINT [FK_tblAreaMap_tblArea]
	FOREIGN KEY ([AreaID]) REFERENCES [dbo].[tblArea] ([AreaID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblAreaMap] ADD CONSTRAINT [FK_tblAreaMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
CREATE NONCLUSTERED INDEX [IXFK_tblAreaMap_tblArea] 
 ON [dbo].[tblAreaMap] ([AreaID] ASC)
GO
CREATE NONCLUSTERED INDEX [IXFK_tblAreaMap_tblConfigurations] 
 ON [dbo].[tblAreaMap] ([ConfigurationID] ASC)