CREATE TABLE [cust].[tblHtml5Map]
(
	[Html5ID] int NOT NULL,
	[ConfigurationID] int NOT NULL,
	[PreviousHtml5ID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [cust].[tblHtml5Map] ADD CONSTRAINT [FK_tblhtml5Map_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [cust].[tblHtml5Map] ADD CONSTRAINT [FK_tblHtml5Map_tblHtml5]
	FOREIGN KEY ([Html5ID]) REFERENCES [cust].[tblHtml5] ([Html5ID]) ON DELETE Cascade ON UPDATE No Action