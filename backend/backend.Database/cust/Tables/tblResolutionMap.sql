CREATE TABLE [cust].[tblResolutionMap]
(
	[ResolutionID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousResolutionID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblResolutionMap] ADD CONSTRAINT [FK_tblResolutionMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblResolutionMap] ADD CONSTRAINT [FK_tblResolutionMap_tblResolution]
	FOREIGN KEY ([ResolutionID]) REFERENCES [cust].[tblResolution] ([ResolutionID]) ON DELETE Cascade ON UPDATE No Action