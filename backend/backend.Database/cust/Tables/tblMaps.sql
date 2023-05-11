CREATE TABLE [cust].[tblMaps]
(
	[MapID] int NOT NULL IDENTITY (1, 1),
	[MapItems] xml NULL,
	[HardwareCaps] xml NULL,
	[Borders] xml NULL,
	[BroadCastBorders] xml NULL
)
GO
ALTER TABLE [cust].[tblMaps] 
 ADD CONSTRAINT [PK_tblMaps]
	PRIMARY KEY CLUSTERED ([MapID] ASC)