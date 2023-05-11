CREATE TABLE [dbo].[tblAsxiWorldGuideText]
(
	[AsxiWorldGuideTextID] int NOT NULL IDENTITY (1, 1),
	[TextID] int NULL,
	[LanguageID] int NULL,
	[DataSourceID] int NULL,
	[LastModifiedDate] timestamp NULL,
	[SourceDate] date NULL,
	[DoSpellCheck] bit NULL DEFAULT 0
)
GO
ALTER TABLE [dbo].[tblAsxiWorldGuideText] 
 ADD CONSTRAINT [PK_tblAsxiWorldGuideText]
	PRIMARY KEY CLUSTERED ([AsxiWorldGuideTextID] ASC)