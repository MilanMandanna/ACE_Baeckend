GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns region spelling for configurationId
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dRegionSpelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dRegionSpelling]
END
GO

CREATE PROC sp_GetExportASXI3dRegionSpelling
@configurationId INT,
@languages VARCHAR(MAX)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)
SET @sql='select 
	*
from (
    select 
		RegionID,
		tblRegionSpelling.CustomChangeBitMask as CustomChangeBit,
		RegionName,
		tblLanguages.[2LetterID_ASXi] as code
    from tblRegionSpelling 
		inner join tblLanguages on tblLanguages.LanguageID = tblRegionSpelling.LanguageId
		inner join tblRegionSpellingMap as rsmap on rsmap.SpellingID = tblRegionSpelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
    where
		rsmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and rsmap.isDeleted=0 and
		lmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and lmap.isDeleted=0
) as sourcetable
pivot(
    max(RegionName)
    for code in ('+@languages+')
) as pivottable
order by RegionID'

EXECUTE sp_executesql @sql;


END
GO