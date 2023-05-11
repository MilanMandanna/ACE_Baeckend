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
/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE [dbo].[Aircraft] 
 ADD CONSTRAINT [PK_dbo.Aircraft]
	PRIMARY KEY CLUSTERED ([Id] ASC)