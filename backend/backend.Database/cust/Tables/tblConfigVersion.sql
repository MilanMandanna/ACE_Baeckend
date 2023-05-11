CREATE TABLE [cust].[tblConfigVersion]
(
	[ConfigVersionID] int NOT NULL IDENTITY (1, 1),
	[Version] xml NULL
)
GO
ALTER TABLE [cust].[tblConfigVersion] 
 ADD CONSTRAINT [PK_tblConfigVersion]
	PRIMARY KEY CLUSTERED ([ConfigVersionID] ASC)