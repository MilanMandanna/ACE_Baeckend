CREATE TABLE [dbo].[DownloadPreferenceAssignment]
(
	[Id] uniqueidentifier NOT NULL,
	[DownloadPreferenceId] uniqueidentifier NOT NULL,
	[PreferenceList] nvarchar(max) NULL,
	[AircraftId] uniqueidentifier NOT NULL
)
GO
ALTER TABLE [dbo].[DownloadPreferenceAssignment] ADD CONSTRAINT [FK_dbo.DownloadPreferenceAssignment_dbo.Aircraft_AircraftId]
	FOREIGN KEY ([AircraftId]) REFERENCES [dbo].[Aircraft] ([Id]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[DownloadPreferenceAssignment] ADD CONSTRAINT [FK_dbo.DownloadPreferenceAssignment_dbo.DownloadPreference_DownloadPreferenceId]
	FOREIGN KEY ([DownloadPreferenceId]) REFERENCES [dbo].[DownloadPreference] ([Id]) ON DELETE Cascade ON UPDATE No Action
GO
ALTER TABLE [dbo].[DownloadPreferenceAssignment] 
 ADD CONSTRAINT [PK_dbo.DownloadPreferenceAssignment]
	PRIMARY KEY CLUSTERED ([Id] ASC)