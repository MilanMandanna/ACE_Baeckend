CREATE TABLE [dbo].[tblLanguages]
(
	[ID] int NOT NULL IDENTITY (1, 1),
	[LanguageID] int NOT NULL,	-- Unique language identifier.
	[Name] nvarchar(100) NULL,	-- Name of the language in English.
	[NativeName] nvarchar(100) NULL,	-- Localized name of the language.
	[Description] nvarchar(255) NULL,
	[ISLatinScript] bit NULL,	-- Indicates whether this language is stored in the database using the Latin alphabet writing system.  0 = false; 1 = true.
	[Tier] smallint NULL,	-- Language grouping. Translations should be made available in all Tier 1 languages.
	[2LetterID_4xxx] nvarchar(50) NULL,	-- 2-character language code used in 4xxx.
	[3LetterID_4xxx] nvarchar(50) NULL,	-- 3-character language code used in 4xxx.
	[2LetterID_ASXi] nvarchar(50) NULL,	-- ISO 639-1 two-character language code used in ASXi.
	[3LetterID_ASXi] nvarchar(50) NULL,	-- ISO 639-2 three-character language code used in ASXi.
	[HorizontalOrder] smallint NULL DEFAULT 0,
	[HorizontalScroll] smallint NULL DEFAULT 0,	-- 0 = use default; 1 = right-to-left; 2 = left-to-right
	[VerticalOrder] smallint NULL DEFAULT 0,	-- 0 = use default; 1 = right-to-left; 2 = left-to-right
	[VerticalScroll] smallint NULL DEFAULT 0
)
GO
ALTER TABLE [dbo].[tblLanguages] 
 ADD CONSTRAINT [PK_tblLanguages]
	PRIMARY KEY CLUSTERED ([ID] ASC)
GO
EXEC sp_addextendedproperty 'MS_Description', 'Unique language identifier.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [LanguageID]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Name of the language in English.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [Name]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Localized name of the language.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [NativeName]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Indicates whether this language is stored in the database using the Latin alphabet writing system.  0 = false; 1 = true.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [ISLatinScript]
GO
EXEC sp_addextendedproperty 'MS_Description', 'Language grouping. Translations should be made available in all Tier 1 languages.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [Tier]
GO
EXEC sp_addextendedproperty 'MS_Description', '2-character language code used in 4xxx.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [2LetterID_4xxx]
GO
EXEC sp_addextendedproperty 'MS_Description', '3-character language code used in 4xxx.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [3LetterID_4xxx]
GO
EXEC sp_addextendedproperty 'MS_Description', 'ISO 639-1 two-character language code used in ASXi.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [2LetterID_ASXi]
GO
EXEC sp_addextendedproperty 'MS_Description', 'ISO 639-2 three-character language code used in ASXi.', 'Schema', [dbo], 'table', [tblLanguages], 'column', [3LetterID_ASXi]
GO
EXEC sp_addextendedproperty 'MS_Description', '0 = use default; 1 = right-to-left; 2 = left-to-right', 'Schema', [dbo], 'table', [tblLanguages], 'column', [HorizontalScroll]
GO
EXEC sp_addextendedproperty 'MS_Description', '0 = use default; 1 = right-to-left; 2 = left-to-right', 'Schema', [dbo], 'table', [tblLanguages], 'column', [VerticalOrder]