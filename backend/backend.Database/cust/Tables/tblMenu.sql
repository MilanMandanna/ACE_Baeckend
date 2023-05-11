CREATE TABLE [cust].[tblMenu]
(
	[MenuID] int NOT NULL IDENTITY (1, 1),
	[Perspective] xml NULL,
	[Layers] xml NULL,
	[IsHTML5] bit NULL DEFAULT 0
)
GO
ALTER TABLE [cust].[tblMenu] 
 ADD CONSTRAINT [PK_tblMenu]
	PRIMARY KEY CLUSTERED ([MenuID] ASC)