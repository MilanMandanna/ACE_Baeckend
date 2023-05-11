CREATE TABLE [cust].[tblHtml5]
(
	[Html5ID] int NOT NULL IDENTITY (1, 1),
	[Category] xml NULL,
	[InfoItems] xml NULL
)
GO
ALTER TABLE [cust].[tblHtml5] 
 ADD CONSTRAINT [PK_tblHtml5]
	PRIMARY KEY CLUSTERED ([Html5ID] ASC)