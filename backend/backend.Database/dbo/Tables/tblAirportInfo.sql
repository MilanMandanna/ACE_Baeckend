CREATE TABLE [dbo].[tblAirportInfo]
(
	[AirportInfoID] int NOT NULL IDENTITY (1, 1),
	[FourLetID] nvarchar(4) NULL,
	[ThreeLetID] nvarchar(3) NULL,
	[Lat] decimal(12,9) NULL,
	[Lon] decimal(12,9) NULL,
	[GeoRefID] int NULL,
	[CityName] nvarchar(255) NULL,
	[DataSourceID] int NULL,
	[ModifyDate] timestamp NOT NULL
)
GO
ALTER TABLE [dbo].[tblAirportInfo] 
 ADD CONSTRAINT [PK_tblAirportInfo]
	PRIMARY KEY CLUSTERED ([AirportInfoID] ASC)