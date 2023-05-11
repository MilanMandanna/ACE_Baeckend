CREATE TABLE [cust].[tblMapsMap]
(
	[MapID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousMapID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblMapsMap] ADD CONSTRAINT [FK_tblMapsMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblMapsMap] ADD CONSTRAINT [FK_tblMapsMap_tblMaps]
	FOREIGN KEY ([MapID]) REFERENCES [cust].[tblMaps] ([MapID]) ON DELETE Cascade ON UPDATE No Action