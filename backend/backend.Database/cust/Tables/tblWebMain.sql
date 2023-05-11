CREATE TABLE [cust].[tblWebMain]
(
	[WebMainID] int NOT NULL IDENTITY (1, 1),
	[WebMainItems] xml NULL,
	[InfoItems] xml NULL
)
GO
ALTER TABLE [cust].[tblWebMain] 
 ADD CONSTRAINT [PK_tblInfoItems]
	PRIMARY KEY CLUSTERED ([WebMainID] ASC)