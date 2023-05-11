CREATE TABLE [dbo].[tblSubscriptionFeature]
(
	[ID] uniqueidentifier NOT NULL,
	[Name] nvarchar(50) NULL,
	[Description] nvarchar(50) NULL,
	[DefaultJSON] nvarchar(max) NULL,
	[EditorJSONSchema] nvarchar(max) NULL,
	[IsObsolete] bit NULL
)
GO
ALTER TABLE [dbo].[tblSubscriptionFeature] 
 ADD CONSTRAINT [PK_tblSubscriptionFeature]
	PRIMARY KEY CLUSTERED ([ID] ASC)