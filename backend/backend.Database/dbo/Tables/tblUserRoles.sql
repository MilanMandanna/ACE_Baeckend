CREATE TABLE [dbo].[UserRoles]
(
	[ID] uniqueidentifier NOT NULL,
	[Name] nvarchar(50) NOT NULL,
	[Description] nvarchar(50) NULL,
	[Hidden] bit NULL,
	[ThirdParty] bit NULL
)
GO
ALTER TABLE [dbo].[UserRoles] 
 ADD CONSTRAINT [PK_dbo.UserRoles]
	PRIMARY KEY CLUSTERED ([ID] ASC,[Name] ASC)