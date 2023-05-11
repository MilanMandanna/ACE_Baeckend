CREATE TABLE [dbo].[tblCoverageSegment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GeoRefID] [int] NULL,
	[SegmentID] [int] NULL,
	[Lat1] [decimal](12, 9) NULL,
	[Lon1] [decimal](12, 9) NULL,
	[Lat2] [decimal](12, 9) NULL,
	[Lon2] [decimal](12, 9) NULL,
	[DataSourceID] [int] NULL,
	[LastModifiedTime] [timestamp] NOT NULL,
	[SourceDate] [date] NULL,
	[CustomChangeBitMask] [int] NOT NULL,
 CONSTRAINT [PK_tblCoverageSegment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCoverageSegment] ADD  DEFAULT ((0)) FOR [CustomChangeBitMask]
GO
