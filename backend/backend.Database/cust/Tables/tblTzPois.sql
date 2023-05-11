CREATE TABLE [cust].[tblTzPois]
(
	[TzPoisID] int NOT NULL IDENTITY (1, 1),
	[TZPois] xml NULL
)
GO
ALTER TABLE [cust].[tblTzPois] 
 ADD CONSTRAINT [PK_tblTzPois]
	PRIMARY KEY CLUSTERED ([TzPoisID] ASC)