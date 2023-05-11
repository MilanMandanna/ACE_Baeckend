CREATE TABLE [dbo].[UserClaims]
(
	[ID] uniqueidentifier NOT NULL,
	[Name] nvarchar(50) NOT NULL,
	[Description] nvarchar(50) NULL,
	[ScopeType] nvarchar(50) NULL
)
GO
ALTER TABLE [dbo].[UserClaims] 
 ADD CONSTRAINT [PK_dbo.UserClaims]
	PRIMARY KEY CLUSTERED ([ID] ASC,[Name] ASC)