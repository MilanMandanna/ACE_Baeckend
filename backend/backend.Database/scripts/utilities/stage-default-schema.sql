/* Drop Foreign Key Constraints */

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1) 
ALTER TABLE [dbo].[AspNetUserLogins] DROP CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_dbo.DownloadPreferenceAssignment_dbo.Aircraft_AircraftId]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1) 
ALTER TABLE [dbo].[DownloadPreferenceAssignment] DROP CONSTRAINT [FK_dbo.DownloadPreferenceAssignment_dbo.Aircraft_AircraftId]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_dbo.DownloadPreferenceAssignment_dbo.DownloadPreference_DownloadPreferenceId]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1) 
ALTER TABLE [dbo].[DownloadPreferenceAssignment] DROP CONSTRAINT [FK_dbo.DownloadPreferenceAssignment_dbo.DownloadPreference_DownloadPreferenceId]
GO

/* Drop Tables */

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[Aircraft]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[Aircraft]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[AspNetUserLogins]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[AspNetUserLogins]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[AspNetUsers]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[AspNetUsers]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DownloadPreference]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[DownloadPreference]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DownloadPreferenceAssignment]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[DownloadPreferenceAssignment]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[InstallationTypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[InstallationTypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[Msu]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[Msu]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MsuConfigurations]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[MsuConfigurations]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[Operator]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) 
DROP TABLE [dbo].[Operator]
GO

/* Create Tables */

CREATE TABLE [dbo].[Aircraft]
(
	[Id] uniqueidentifier NOT NULL,
	[ConnectivityTypes] nvarchar(max) NULL,
	[ContentDiskSpace] int NOT NULL,
	[CreatedByUserId] uniqueidentifier NOT NULL,
	[DateCreated] datetimeoffset(7) NOT NULL,
	[DateModified] datetimeoffset(7) NULL,
	[IsDeleted] bit NOT NULL,
	[LastManifestCreatedDate] datetimeoffset(7) NULL,
	[Manufacturer] nvarchar(max) NULL,
	[Model] nvarchar(max) NULL,
	[ModifiedBy] nvarchar(max) NULL,
	[OperatorId] uniqueidentifier NOT NULL,
	[SerialNumber] nvarchar(max) NULL,
	[TailNumber] nvarchar(max) NULL,
	[Password] nvarchar(max) NULL,
	[LastPasswordChange] datetimeoffset(7) NULL,
	[SelectedAssetsCount] bigint NOT NULL DEFAULT 0,
	[SelectedAssetsSize] bigint NOT NULL DEFAULT 0,
	[InstallationTypeId] uniqueidentifier NULL,
	[ThirdPartyRoleID] uniqueidentifier NULL
)
GO

CREATE TABLE [dbo].[AspNetUserLogins]
(
	[LoginProvider] nvarchar(128) NOT NULL,
	[ProviderKey] nvarchar(128) NOT NULL,
	[UserId] uniqueidentifier NOT NULL
)
GO

CREATE TABLE [dbo].[AspNetUsers]
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
GO

CREATE TABLE [dbo].[DownloadPreference]
(
	[Id] uniqueidentifier NOT NULL,
	[AssetType] int NOT NULL,
	[Name] nvarchar(max) NULL,
	[Title] nvarchar(max) NULL
)
GO

CREATE TABLE [dbo].[DownloadPreferenceAssignment]
(
	[Id] uniqueidentifier NOT NULL,
	[DownloadPreferenceId] uniqueidentifier NOT NULL,
	[PreferenceList] nvarchar(max) NULL,
	[AircraftId] uniqueidentifier NOT NULL
)
GO

CREATE TABLE [dbo].[InstallationTypes]
(
	[ID] uniqueidentifier NOT NULL,
	[InstallationTypeValue] nvarchar(50) NULL,
	[SupportedConnectionType] nvarchar(50) NULL,
	[StageClientTypeId] uniqueidentifier NULL,
	[MediaStorageSize] bigint NULL
)
GO

CREATE TABLE [dbo].[Msu]
(
	[ID] uniqueidentifier NOT NULL,
	[PartNumber] nvarchar(max) NULL,
	[SerialNumber] nvarchar(max) NULL,
	[AircraftId] uniqueidentifier NULL,
	[IsDeleted] bit NULL,
	[InitializationDate] datetimeoffset(7) NULL,
	[LastSyncDate] datetimeoffset(7) NULL,
	[StatusUpdateDate] datetimeoffset(7) NULL,
	[PublicKey] nvarchar(max) NULL
)
GO

CREATE TABLE [dbo].[MsuConfigurations]
(
	[ID] uniqueidentifier NOT NULL,
	[TailNumber] nvarchar(max) NULL,
	[FileName] nvarchar(max) NULL,
	[ConfigurationBody] nvarchar(max) NULL,
	[DateCreated] datetimeoffset(7) NULL
)
GO

CREATE TABLE [dbo].[Operator]
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


/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE [dbo].[Aircraft] 
 ADD CONSTRAINT [PK_dbo.Aircraft]
	PRIMARY KEY CLUSTERED ([Id] ASC)
GO

ALTER TABLE [dbo].[AspNetUserLogins] 
 ADD CONSTRAINT [PK_dbo.AspNetUserLogins]
	PRIMARY KEY CLUSTERED ([LoginProvider] ASC,[ProviderKey] ASC,[UserId] ASC)
GO

ALTER TABLE [dbo].[AspNetUsers] 
 ADD CONSTRAINT [PK_dbo.AspNetUsers]
	PRIMARY KEY CLUSTERED ([Id] ASC)
GO

ALTER TABLE [dbo].[DownloadPreference] 
 ADD CONSTRAINT [PK_dbo.DownloadPreference]
	PRIMARY KEY CLUSTERED ([Id] ASC)
GO

ALTER TABLE [dbo].[DownloadPreferenceAssignment] 
 ADD CONSTRAINT [PK_dbo.DownloadPreferenceAssignment]
	PRIMARY KEY CLUSTERED ([Id] ASC)
GO

ALTER TABLE [dbo].[InstallationTypes] 
 ADD CONSTRAINT [PK_InstallationTypes]
	PRIMARY KEY CLUSTERED ([ID] ASC)
GO

ALTER TABLE [dbo].[Msu] 
 ADD CONSTRAINT [PK_Msu]
	PRIMARY KEY CLUSTERED ([ID] ASC)
GO

ALTER TABLE [dbo].[MsuConfigurations] 
 ADD CONSTRAINT [PK_MsuConfigurations]
	PRIMARY KEY CLUSTERED ([ID] ASC)
GO

ALTER TABLE [dbo].[Operator] 
 ADD CONSTRAINT [PK_dbo.Operator]
	PRIMARY KEY CLUSTERED ([Id] ASC)
GO


/* Create Foreign Key Constraints */

ALTER TABLE [dbo].[AspNetUserLogins] ADD CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
	FOREIGN KEY ([UserId]) REFERENCES  [dbo].[AspNetUsers] ([Id]) ON DELETE Cascade ON UPDATE No Action
GO

ALTER TABLE [dbo].[DownloadPreferenceAssignment] ADD CONSTRAINT [FK_dbo.DownloadPreferenceAssignment_dbo.Aircraft_AircraftId]
	FOREIGN KEY ([AircraftId]) REFERENCES [dbo].[Aircraft] ([Id]) ON DELETE Cascade ON UPDATE No Action
GO

ALTER TABLE [dbo].[DownloadPreferenceAssignment] ADD CONSTRAINT [FK_dbo.DownloadPreferenceAssignment_dbo.DownloadPreference_DownloadPreferenceId]
	FOREIGN KEY ([DownloadPreferenceId]) REFERENCES [dbo].[DownloadPreference] ([Id]) ON DELETE Cascade ON UPDATE No Action
GO
