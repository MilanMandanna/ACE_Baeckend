CREATE TABLE [cust].[tblGlobal]
(
	[CustomID] int NOT NULL IDENTITY (1, 1),
	[Global] xml NULL,
	[AirportLanguage] xml NULL
)
GO
ALTER TABLE [cust].[tblGlobal] 
 ADD CONSTRAINT [PK_tblCustom]
	PRIMARY KEY CLUSTERED ([CustomID] ASC)