CREATE TABLE [cust].[tblModeDefs]
(
	[ModeDefID] int NOT NULL IDENTITY (1, 1),
	[ModeDefs] xml NULL DEFAULT NULL
)
GO
ALTER TABLE [cust].[tblModeDefs] 
 ADD CONSTRAINT [PK_tblModeDefs]
	PRIMARY KEY CLUSTERED ([ModeDefID] ASC)