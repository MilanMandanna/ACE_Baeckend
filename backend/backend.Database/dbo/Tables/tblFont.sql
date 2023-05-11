CREATE TABLE [dbo].[tblFont]
(
	[FontID] int NOT NULL,
	[Description] nvarchar(255) NULL,
	[Size] int NULL,
	[Color] nvarchar(8) NULL,
	[ShadowColor] nvarchar(8) NULL,
	[FontFaceId] nvarchar(11) NULL,
	[FontStyle] nvarchar(10) NULL
)
GO
ALTER TABLE [dbo].[tblFont] 
 ADD CONSTRAINT [PK_tblFont]
	PRIMARY KEY CLUSTERED ([FontID] ASC)