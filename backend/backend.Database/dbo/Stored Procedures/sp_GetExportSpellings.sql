GO

-- =============================================
-- Author:		Sathya
-- Create date: 21-Dec-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportSpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportSpellings]
END
GO
CREATE PROC sp_GetExportSpellings
@configurationId INT,
@languages NVARCHAR(MAX)
AS
BEGIN

DECLARE @sql nvarchar(max)

set @sql = 'select 
	*
from (
    select 
		tblspelling.GeoRefID,
		tblspelling.UnicodeStr,
		tblLanguages.[2LetterID_ASXi] as code
    from tblspelling
		inner join tblLanguages on tblLanguages.LanguageID = tblspelling.LanguageID
		inner join tblSpellingMap as smap on smap.SpellingID = tblspelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
    where
		georefid NOT BETWEEN 20200 AND 25189 and
		georefid NOT BETWEEN 200172 AND 200239 and
		georefid NOT BETWEEN 300000 AND 307840 and
		georefid NOT BETWEEN 310000 AND 414100 and
		smap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and smap.IsDeleted=0 and
		lmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ('+@languages+')
) as pivottable
order by GeoRefId'

EXECUTE sp_executesql @sql;


END

GO