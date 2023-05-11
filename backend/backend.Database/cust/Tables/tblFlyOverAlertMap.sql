CREATE TABLE [cust].[tblFlyOverAlertMap]
(
	[FlyOverAlertID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousFlyOverAlertID] int NULL,
	[IsDeleted] bit NULL,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblFlyOverAlertMap] ADD CONSTRAINT [FK_tblFlyOverAlertMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblFlyOverAlertMap] ADD CONSTRAINT [FK_tblFlyOverAlertMap_tblFlyOverAlert]
	FOREIGN KEY ([FlyOverAlertID]) REFERENCES [cust].[tblFlyOverAlert] ([FlyOverAlertID]) ON DELETE Cascade ON UPDATE No Action