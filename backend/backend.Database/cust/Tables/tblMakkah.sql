CREATE TABLE [cust].[tblMakkah]
(
	[MakkahID] int NOT NULL IDENTITY (1, 1),
	[Makkah] xml NULL
)
GO
ALTER TABLE [cust].[tblMakkah] 
 ADD CONSTRAINT [PK_tblMakkah]
	PRIMARY KEY CLUSTERED ([MakkahID] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'Encapsulates the configuration information for the makkah feature', 'SCHEMA', 'cust', 'table', 'tblMakkah'