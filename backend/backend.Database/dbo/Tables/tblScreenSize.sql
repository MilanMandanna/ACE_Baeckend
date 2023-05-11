CREATE TABLE [dbo].[tblScreenSize]
(
	[ScreenSizeID] int NOT NULL,
	[Description] nvarchar(255) NULL
)
GO
ALTER TABLE [dbo].[tblScreenSize] 
 ADD CONSTRAINT [PK_tblScreenSize]
	PRIMARY KEY CLUSTERED ([ScreenSizeID] ASC)