CREATE TABLE [cust].[tblFlyOverAlert]
(
	[FlyOverAlertID] int NOT NULL IDENTITY (1, 1),
	[FlyOverAlert] xml NULL
)
GO
ALTER TABLE [cust].[tblFlyOverAlert] 
 ADD CONSTRAINT [PK_tblFlyOverAlert]
	PRIMARY KEY CLUSTERED ([FlyOverAlertID] ASC)