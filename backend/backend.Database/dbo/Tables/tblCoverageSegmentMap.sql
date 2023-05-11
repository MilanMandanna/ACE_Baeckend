CREATE TABLE [dbo].[tblCoverageSegmentMap](
	[ConfigurationID] [int] NULL,
	[CoverageSegmentID] [int] NULL,
	[PreviousCoverageSegmentID] [int] NULL,
	[IsDeleted] [bit] NULL,
	[TimeStampModified] [timestamp] NULL,
	[LastModifiedBy] [nvarchar](50) NULL,
	[Action] [nvarchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCoverageSegmentMap] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[tblCoverageSegmentMap]  WITH CHECK ADD  CONSTRAINT [FK_tblCoverageSegmentMap_tblConfigurations] FOREIGN KEY([ConfigurationID])
REFERENCES [dbo].[tblConfigurations] ([ConfigurationID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblCoverageSegmentMap] CHECK CONSTRAINT [FK_tblCoverageSegmentMap_tblConfigurations]
GO
ALTER TABLE [dbo].[tblCoverageSegmentMap]  WITH CHECK ADD  CONSTRAINT [FK_tblCoverageSegmentMap_tblCoverageSegment] FOREIGN KEY([CoverageSegmentID])
REFERENCES [dbo].[tblCoverageSegment] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblCoverageSegmentMap] CHECK CONSTRAINT [FK_tblCoverageSegmentMap_tblCoverageSegment]
GO