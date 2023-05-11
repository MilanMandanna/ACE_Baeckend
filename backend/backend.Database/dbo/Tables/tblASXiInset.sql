CREATE TABLE [dbo].[tblASXiInset]
(
	[ASXiInsetID] int NOT NULL IDENTITY (1, 1),
	[InsetName] nvarchar(50) NULL,
	[Zoom] float NULL,
	[Path] nvarchar(max) NULL,
	[MapPackageType] nvarchar(50) NULL,
	[RowStart] int NULL,
	[RowEnd] int NULL,
	[ColStart] int NULL,
	[ColEnd] int NULL,
	[LatStart] float NULL,
	[LatEnd] float NULL,
	[LongStart] float NULL,
	[LongEnd] float NULL,
	[IsHf] bit NULL,
	[PartNumber] int NULL,
	[Cdata] varchar(max) NULL, 
    [IsUHF] BIT NULL
)
GO
ALTER TABLE [dbo].[tblASXiInset] 
 ADD CONSTRAINT [PK_tblASXiInset]
	PRIMARY KEY CLUSTERED ([ASXiInsetID] ASC)