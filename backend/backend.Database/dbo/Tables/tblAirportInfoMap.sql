CREATE TABLE [dbo].[tblAirportInfoMap]
(
	[ConfigurationID] int NULL,
	[AirportInfoID] int NULL,
	[PreviousAirportInfoID] int NULL,
	[IsDeleted] bit NULL DEFAULT 0,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblAirportInfoMap] ADD CONSTRAINT [FK_tblAirportInfoMap_tblAirportInfo]
	FOREIGN KEY ([AirportInfoID]) REFERENCES [dbo].[tblAirportInfo] ([AirportInfoID]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblAirportInfoMap] ADD CONSTRAINT [FK_tblAirportInfoMap_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE Cascade ON UPDATE No Action