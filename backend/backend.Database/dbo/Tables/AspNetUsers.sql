﻿CREATE TABLE [dbo].[AspNetUsers]
(
	[Id] uniqueidentifier NOT NULL,
	[DateCreated] datetimeoffset(7) NOT NULL,
	[DateModified] datetimeoffset(7) NULL,
	[Fax] nvarchar(max) NULL,
	[FirstName] nvarchar(max) NULL,
	[IsDeleted] bit NOT NULL,
	[IsPasswordChangeRequired] bit NOT NULL,
	[IsRememberMe] bit NOT NULL,
	[IsSubscribedForNewsLetter] bit NOT NULL,
	[IsSystemUser] bit NOT NULL,
	[LastName] nvarchar(max) NULL,
	[Company] nvarchar(max) NULL,
	[LastResetDate] datetimeoffset(7) NULL,
	[ModifiedBy] nvarchar(max) NULL,
	[ResetToken] uniqueidentifier NULL,
	[ResetTokenExpirationTime] int NOT NULL,
	[SelectedOperatorId] uniqueidentifier NULL,
	[Email] nvarchar(256) NULL,
	[EmailConfirmed] bit NOT NULL,
	[PasswordHash] nvarchar(max) NULL,
	[SecurityStamp] nvarchar(max) NULL,
	[PhoneNumber] nvarchar(max) NULL,
	[PhoneNumberConfirmed] bit NOT NULL,
	[TwoFactorEnabled] bit NOT NULL,
	[LockoutEndDateUtc] datetimeoffset(7) NULL,
	[LockoutEnabled] bit NOT NULL,
	[AccessFailedCount] int NOT NULL,
	[UserName] nvarchar(256) NOT NULL
)