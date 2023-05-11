CREATE TABLE [dbo].[tblInfoSpelling]
(
	[InfoSpellingId] int NOT NULL IDENTITY,
	[InfoId] int NOT NULL,
	[LanguageId] int NOT NULL,
	[Spelling] nvarchar(max) NULL, 
    CONSTRAINT [PK_tblInfoSpelling_InfoSpellingID] PRIMARY KEY ([InfoSpellingID])
)
GO
