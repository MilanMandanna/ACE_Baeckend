CREATE TABLE [cust].[tblResolution]
(
	[ResolutionID] int NOT NULL IDENTITY (1, 1),
	[Resolution] xml NULL
)
GO
ALTER TABLE [cust].[tblResolution] 
 ADD CONSTRAINT [PK_tblResolution]
	PRIMARY KEY CLUSTERED ([ResolutionID] ASC)