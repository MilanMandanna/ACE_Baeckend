CREATE TABLE [dbo].[tblAppearance](
	[AppearanceID] [int] IDENTITY(1,1) NOT NULL,
	[GeoRefID] [int] NULL,
	[Resolution] [decimal](18, 10) NULL, -- Map resolution expressed in arcseconds.  A value of 0 indicates N/A.
	[ResolutionMpp] [int] NULL,
	[Exclude] [bit] NULL, -- Indicates whether to hide the place name on 2-D maps.
	[SphereMapExclude] [bit] NULL, -- Indicates whether to hide the place name on 3-D maps.
	[CustomChangeBitMask] [int] NOT NULL,
 CONSTRAINT [PK_tblAppearance] PRIMARY KEY CLUSTERED 
(
	[AppearanceID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
