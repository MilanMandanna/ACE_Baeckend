CREATE TABLE [dbo].[tblWGtext]
(
	[WGtextID] int NOT NULL IDENTITY (1, 1),
	[TextID] int NULL,
	[Text_EN] nvarchar(max) NULL,
	[Text_FR] nvarchar(max) NULL,
	[Text_DE] nvarchar(max) NULL,
	[Text_ES] nvarchar(max) NULL,
	[Text_NL] nvarchar(max) NULL,
	[Text_IT] nvarchar(max) NULL,
	[Text_EL] nvarchar(max) NULL,
	[Text_JA] nvarchar(max) NULL,
	[Text_ZH] nvarchar(max) NULL,
	[Text_KO] nvarchar(max) NULL,
	[Text_ID] nvarchar(max) NULL,
	[Text_AR] nvarchar(max) NULL,
	[Text_TR] nvarchar(max) NULL,
	[Text_MS] nvarchar(max) NULL,
	[Text_FI] nvarchar(max) NULL,
	[Text_HI] nvarchar(max) NULL,
	[Text_RU] nvarchar(max) NULL,
	[Text_PT] nvarchar(max) NULL,
	[Text_TH] nvarchar(max) NULL,
	[Text_RO] nvarchar(max) NULL,
	[Text_SR] nvarchar(max) NULL,
	[Text_SV] nvarchar(max) NULL,
	[Text_HU] nvarchar(max) NULL,
	[Text_HE] nvarchar(max) NULL,
	[Text_PL] nvarchar(max) NULL,
	[Text_HK] nvarchar(max) NULL,
	[Text_SM] nvarchar(max) NULL,
	[Text_TO] nvarchar(max) NULL,
	[Text_CS] nvarchar(max) NULL,
	[Text_DA] nvarchar(max) NULL,
	[Text_IS] nvarchar(max) NULL,
	[Text_VI] nvarchar(max) NULL
)
GO
ALTER TABLE [dbo].[tblWGtext] 
 ADD CONSTRAINT [PK_tblWGtext]
	PRIMARY KEY CLUSTERED ([WGtextID] ASC)