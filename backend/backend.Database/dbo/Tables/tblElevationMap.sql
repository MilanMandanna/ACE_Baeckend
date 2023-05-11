CREATE TABLE [dbo].[tblElevationMap]
(
	[ConfigurationID] int NULL,
	[ElevationID] int NULL,
	[PreviousElevationID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblElevationMap] ADD CONSTRAINT [FK_tblElevationMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblElevationMap] ADD CONSTRAINT [FK_tblElevationMap_tblElevation]
	FOREIGN KEY ([ElevationID]) REFERENCES [dbo].[tblElevation] ([ID]) ON DELETE Cascade ON UPDATE No Action