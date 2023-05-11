CREATE TABLE [cust].[tblHandSet]
(
	[HandSetID] int NOT NULL IDENTITY (1, 1),
	[HandSet] xml NULL
)
GO
ALTER TABLE [cust].[tblHandSet] 
 ADD CONSTRAINT [PK_tblHandSet]
	PRIMARY KEY CLUSTERED ([HandSetID] ASC)