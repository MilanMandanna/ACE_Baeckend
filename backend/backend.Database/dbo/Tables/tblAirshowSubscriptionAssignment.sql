CREATE TABLE [dbo].[tblAirshowSubscriptionAssignment]
(
	[ID] uniqueidentifier NOT NULL,
	[ConfigurationDefinitionID] int NULL,
	[SubscriptionID] uniqueidentifier NULL,
	[DateNextSubscriptionCheck] datetime NULL,
	[IsActive] bit NULL
)
GO
ALTER TABLE [dbo].[tblAirshowSubscriptionAssignment] ADD CONSTRAINT [FK_tblAirshowSubscriptionAssignment_tblConfigurationDefinitions]
	FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblAirshowSubscriptionAssignment] ADD CONSTRAINT [FK_tblAirshowSubscriptionAssignment_tblSubscription]
	FOREIGN KEY ([SubscriptionID]) REFERENCES [dbo].[tblSubscription] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblAirshowSubscriptionAssignment] 
 ADD CONSTRAINT [PK_tblAirshowSubscriptionAssignment]
	PRIMARY KEY CLUSTERED ([ID] ASC)