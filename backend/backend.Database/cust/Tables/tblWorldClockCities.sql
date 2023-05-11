CREATE TABLE [cust].[tblWorldClockCities]
(
	[WorldClockCityID] int NOT NULL,
	[WorldClockCities] xml NULL
)
GO
ALTER TABLE [cust].[tblWorldClockCities] 
 ADD CONSTRAINT [PK_WorldClockCities]
	PRIMARY KEY CLUSTERED ([WorldClockCityID] ASC)