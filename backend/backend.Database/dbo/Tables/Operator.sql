﻿CREATE TABLE [dbo].[Operator]
(
	[Id] uniqueidentifier NOT NULL,
	[City] nvarchar(max) NULL,
	[Code] int NULL,
	[Company] nvarchar(max) NULL,
	[Country] nvarchar(max) NULL,
	[CreatedByUserId] uniqueidentifier NOT NULL,
	[DateCreated] datetimeoffset(7) NOT NULL,
	[DateModified] datetimeoffset(7) NULL,
	[Email] nvarchar(max) NULL,
	[Fax] nvarchar(max) NULL,
	[FirstName] nvarchar(max) NULL,
	[IsDeleted] bit NOT NULL,
	[JobTitle] nvarchar(max) NULL,
	[LastName] nvarchar(max) NULL,
	[ModifiedBy] nvarchar(max) NULL,
	[Name] nvarchar(max) NULL,
	[PhoneNumber] nvarchar(max) NULL,
	[PostalCode] nvarchar(max) NULL,
	[Salutation] int NOT NULL,
	[SecondaryCity] nvarchar(max) NULL,
	[SecondaryCompany] nvarchar(max) NULL,
	[SecondaryCountry] nvarchar(max) NULL,
	[SecondaryEmail] nvarchar(max) NULL,
	[SecondaryFax] nvarchar(max) NULL,
	[SecondaryFirstName] nvarchar(max) NULL,
	[SecondaryJobTitle] nvarchar(max) NULL,
	[SecondaryLastName] nvarchar(max) NULL,
	[SecondaryPhoneNumber] nvarchar(max) NULL,
	[SecondaryPostalCode] nvarchar(max) NULL,
	[SecondarySalutation] int NOT NULL,
	[SecondaryState] nvarchar(max) NULL,
	[State] nvarchar(max) NULL,
	[AddressLine2] nvarchar(max) NULL,
	[SecondaryAddressLine1] nvarchar(max) NULL,
	[SecondaryAddressLine2] nvarchar(max) NULL,
	[AddressLine1] nvarchar(max) NULL,
	[IsTest] bit NOT NULL DEFAULT 0,
	[ManageRoleID] uniqueidentifier NULL,
	[ViewRoleID] uniqueidentifier NULL
)
GO
ALTER TABLE [dbo].[Operator] 
 ADD CONSTRAINT [PK_dbo.Operator]
	PRIMARY KEY CLUSTERED ([Id] ASC)