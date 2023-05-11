﻿CREATE TABLE [cust].[tblNews]
(
	[NewsID] int NOT NULL IDENTITY (1, 1),
	[News] xml NULL DEFAULT NULL
)
GO
ALTER TABLE [cust].[tblNews] 
 ADD CONSTRAINT [PK_tblNews]
	PRIMARY KEY CLUSTERED ([NewsID] ASC)