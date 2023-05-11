CREATE TABLE [dbo].[tblUSStates]
(
	[StateID] nvarchar(2) NOT NULL,
	[StateName] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[tblUSStates] 
 ADD CONSTRAINT [PK_tblUsStates]
	PRIMARY KEY CLUSTERED ([StateID] ASC)