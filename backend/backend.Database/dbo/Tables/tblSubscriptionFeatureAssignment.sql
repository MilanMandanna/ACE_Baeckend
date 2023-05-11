CREATE TABLE [dbo].[tblSubscriptionFeatureAssignment]
(
	[ID] uniqueidentifier NOT NULL,
	[SubscriptionID] uniqueidentifier NULL,
	[SubscriptionFeatureID] uniqueidentifier NULL,
	[ConfigurationJSON] nvarchar(max) NULL
)
GO
ALTER TABLE [dbo].[tblSubscriptionFeatureAssignment] ADD CONSTRAINT [FK_tblSubscriptionFeatureAssignment_tblSubscription]
	FOREIGN KEY ([SubscriptionID]) REFERENCES [dbo].[tblSubscription] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblSubscriptionFeatureAssignment] ADD CONSTRAINT [FK_tblSubscriptionFeatureAssignment_tblSubscriptionFeature]
	FOREIGN KEY ([SubscriptionFeatureID]) REFERENCES [dbo].[tblSubscriptionFeature] ([ID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblSubscriptionFeatureAssignment] 
 ADD CONSTRAINT [PK_tblSubscriptionFeatureAssignment]
	PRIMARY KEY CLUSTERED ([ID] ASC)