CREATE TABLE [dbo].[tblFontTextEffect]
(
	[FontTextEffectID] int NOT NULL,
	[Name] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblFontTextEffect] 
 ADD CONSTRAINT [PK_tblFontTextEffect]
	PRIMARY KEY CLUSTERED ([FontTextEffectID] ASC)