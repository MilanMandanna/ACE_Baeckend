CREATE TABLE [cust].[tblTzPoisMap]
(
	[TzPoisID] int NULL,
	[ConfigurationID] int NULL,
	[PreviousTzPoisID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblTzPoisMap] ADD CONSTRAINT [FK_tblTzPoisMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action