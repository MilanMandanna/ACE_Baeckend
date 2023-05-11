CREATE TABLE [dbo].[tblTempWGDetailedFlightInfo]
(
	[Id] INT NOT NULL IDENTITY (1, 1), 
	[GeoRefID] INT NULL, 
    [Overview] NVARCHAR(MAX) NULL, 
    [Features] NVARCHAR(MAX) NULL, 
    [Sights] NVARCHAR(MAX) NULL, 
    [Stats] NVARCHAR(MAX) NULL, 
    [ImageFileName] NVARCHAR(250) NULL, 
    [Text_EN] NVARCHAR(MAX) NULL
)
