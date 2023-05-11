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
ALTER TABLE [dbo].[Msu] 
 ADD CONSTRAINT [PK_Msu]
	PRIMARY KEY CLUSTERED ([ID] ASC)