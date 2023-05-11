CREATE TABLE [dbo].[tblTimeZoneStrip]
(
	[ID] int NOT NULL IDENTITY (1, 1),
	[TZStripID] int NULL,
	[Description] nvarchar(255) NULL,
	[IdVer1] int NULL,	-- Time zone strip identifier used in ASX (4XXX, 500, Venue, etc.) and pre-ASXi 4.0 configs.
	[IdVer2] int NULL	-- Time zone strip identifier used in ASXi 4.x configs.
)
GO
ALTER TABLE [dbo].[tblTimeZoneStrip] 
 ADD CONSTRAINT [PK_tblTimeZoneStrip]
	PRIMARY KEY CLUSTERED ([ID] ASC)
GO
EXEC sp_addextendedproperty 'MS_Description', 'Time zone strip identifier used in ASX (4XXX, 500, Venue, etc.) and pre-ASXi 4.0 configs.', 'Schema', [dbo], 'table', [tblTimeZoneStrip], 'column', [IdVer1]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Time zone strip identifier used in ASXi 4.x configs.', 'Schema', [dbo], 'table', [tblTimeZoneStrip], 'column', [IdVer2]