CREATE TABLE [cust].[tblPersonalityListMap]
(
	[ConfigurationID] int NULL,
	[PersonalityListID] int NULL,
	[PreviousPersonalityListID] int NULL,
	[isDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblPersonalityListMap] ADD CONSTRAINT [FK_tblPersonalityListMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblPersonalityListMap] ADD CONSTRAINT [FK_tblPersonalityListMap_tblPersonalityList]
	FOREIGN KEY ([PersonalityListID]) REFERENCES [cust].[tblPersonalityList] ([PersonalityListID]) ON DELETE Cascade ON UPDATE No Action