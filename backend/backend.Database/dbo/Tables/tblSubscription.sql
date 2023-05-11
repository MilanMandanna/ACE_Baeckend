CREATE TABLE [dbo].[tblSubscription]
(
	[ID] uniqueidentifier NOT NULL,
	[Name] nvarchar(50) NULL,
	[Description] nvarchar(500) NULL,
	[IsObsolete] bit NULL,
	[DateCreated] datetime NULL,
	[DateLastModified] timestamp NULL
)
GO
ALTER TABLE [dbo].[tblSubscription] 
 ADD CONSTRAINT [PK_tblSubscription]
	PRIMARY KEY CLUSTERED ([ID] ASC)