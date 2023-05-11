CREATE TABLE [cust].[tblPersonalityList]
(
	[PersonalityListID] int NOT NULL IDENTITY (1, 1),
	[Personality] xml NULL
)
GO
ALTER TABLE [cust].[tblPersonalityList] 
 ADD CONSTRAINT [PK_tblPersonalityList]
	PRIMARY KEY CLUSTERED ([PersonalityListID] ASC)