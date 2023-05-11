CREATE TABLE [dbo].[tblFontMarker]
(
	[FontMarkerID] int NOT NULL,
	[MarkerID] int NOT NULL DEFAULT 0,
	[Filename] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblFontMarker] 
 ADD CONSTRAINT [PK_tblFontMarker]
	PRIMARY KEY CLUSTERED ([FontMarkerID] ASC)