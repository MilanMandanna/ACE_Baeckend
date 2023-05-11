CREATE TABLE [cust].[tblTickerMap]
(
	[TickerID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousTickerID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblTickerMap] ADD CONSTRAINT [FK_tblTickerMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblTickerMap] ADD CONSTRAINT [FK_tblTickerMap_tblTicker]
	FOREIGN KEY ([TickerID]) REFERENCES [cust].[tblTicker] ([TickerID]) ON DELETE Cascade ON UPDATE No Action