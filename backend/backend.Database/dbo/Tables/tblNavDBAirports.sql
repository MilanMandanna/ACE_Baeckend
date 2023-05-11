CREATE TABLE [dbo].[tblNavDBAirports]
(
	[FourLetId] NVARCHAR(10) NULL , 
    [ThreeLetId] NVARCHAR(10) NULL, 
    [Lat] NVARCHAR(50) NULL, 
    [Long] NVARCHAR(50) NULL, 
    [Description] NVARCHAR(250) NULL, 
    [City] NVARCHAR(50) NULL, 
    [SN] INT NULL, 
    [existingGeorefId] INT NULL
)
