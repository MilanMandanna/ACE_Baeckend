CREATE TABLE [dbo].[tblTempWGCityFlightInfo]
(
	[Id] INT NOT NULL IDENTITY(1,1), 
    [ImageFileName] NCHAR(250) NULL, 
    [Description] NVARCHAR(MAX) NULL, 
    [Language] NVARCHAR(250) NULL, 
    [GeoRefID] INT NULL
)
