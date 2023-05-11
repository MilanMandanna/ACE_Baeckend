CREATE TABLE [cust].[tblMiqat]
(
	[MiqatID] int NOT NULL IDENTITY (1, 1),
	[Miqat] xml NULL
)
GO
ALTER TABLE [cust].[tblMiqat] 
 ADD CONSTRAINT [PK_tblMiqat]
	PRIMARY KEY CLUSTERED ([MiqatID] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'captures the configuration information for the miqat feature in ASXi', 'SCHEMA', 'cust', 'table', 'tblMiqat'