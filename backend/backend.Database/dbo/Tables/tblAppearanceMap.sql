CREATE TABLE [dbo].[tblAppearanceMap](
	[ConfigurationID] [int] NULL,
	[AppearanceID] [int] NULL,
	[PreviousAppearanceID] [int] NULL,
	[IsDeleted] [bit] NULL,
	[TimeStampModified] [timestamp] NULL,
	[LastModifiedBy] [nvarchar](50) NULL,
	[Action] [nvarchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAppearanceMap]  WITH CHECK ADD  CONSTRAINT [FK_tblAppearanceMap_tblAppearance] FOREIGN KEY([AppearanceID])
REFERENCES [dbo].[tblAppearance] ([AppearanceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblAppearanceMap] CHECK CONSTRAINT [FK_tblAppearanceMap_tblAppearance]