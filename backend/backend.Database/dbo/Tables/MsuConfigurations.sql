CREATE TABLE [dbo].[MsuConfigurations]
(
	[ID] uniqueidentifier NOT NULL,
	[TailNumber] nvarchar(max) NULL,
	[FileName] nvarchar(max) NULL,
	[ConfigurationBody] nvarchar(max) NULL,
	[DateCreated] datetimeoffset(7) NULL
)
GO
ALTER TABLE [dbo].[MsuConfigurations] 
 ADD CONSTRAINT [PK_MsuConfigurations]
	PRIMARY KEY CLUSTERED ([ID] ASC)