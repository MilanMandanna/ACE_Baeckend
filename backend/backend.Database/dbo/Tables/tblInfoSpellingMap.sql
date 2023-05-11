CREATE TABLE [dbo].[tblInfoSpellingMap]
(
	[ConfigurationID] int NULL,
	[InfoSpellingID] int NULL,
	[PreviousInfoSpellingID] int NULL,
	[IsDeleted] bit NULL,
	[TimeStampModified] timestamp NOT NULL,
	[LastModifiedBy] nvarchar(50) NULL,
	[Action] nvarchar(50) NULL, 
	CONSTRAINT [FK_tblInfoSpellingMap_tblInfoSpelling] FOREIGN KEY ([InfoSpellingID]) REFERENCES [dbo].[tblInfoSpelling]([InfoSpellingID])
)
GO