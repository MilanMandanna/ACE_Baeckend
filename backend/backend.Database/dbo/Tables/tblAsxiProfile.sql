CREATE TABLE [dbo].[tblAsxiProfile]
(
	[AsxiProfileID] int NOT NULL IDENTITY (1, 1),
	[AsxiProfile] xml NULL
)
GO
ALTER TABLE [dbo].[tblAsxiProfile] 
 ADD CONSTRAINT [PK_tblAsxiProfile]
	PRIMARY KEY CLUSTERED ([AsxiProfileID] ASC)