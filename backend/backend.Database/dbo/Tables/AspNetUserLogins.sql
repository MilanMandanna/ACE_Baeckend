CREATE TABLE [dbo].[AspNetUserLogins]
(
	[LoginProvider] nvarchar(128) NOT NULL,
	[ProviderKey] nvarchar(128) NOT NULL,
	[UserId] uniqueidentifier NOT NULL
)
GO
ALTER TABLE [dbo].[AspNetUserLogins] 
 ADD CONSTRAINT [PK_dbo.AspNetUserLogins]
	PRIMARY KEY CLUSTERED ([LoginProvider] ASC,[ProviderKey] ASC,[UserId] ASC)