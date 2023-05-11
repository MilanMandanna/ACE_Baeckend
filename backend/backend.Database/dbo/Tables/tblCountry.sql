CREATE TABLE [dbo].[tblCountry]
(
	[CountryID] int NOT NULL IDENTITY (1, 1),
	[Description] nvarchar(50) NULL,
	[CountryCode] nvarchar(2) NULL,
	[ISO3166Code] nvarchar(2) NULL,
	[RegionID] int NULL
)
GO
ALTER TABLE [dbo].[tblCountry] 
 ADD CONSTRAINT [PK_tblCountry]
	PRIMARY KEY CLUSTERED ([CountryID] ASC)