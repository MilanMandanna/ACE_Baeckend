GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSESpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSESpellings]
END
GO
CREATE PROC sp_GetExportCESHTSESpellings
@configurationId INT
AS
BEGIN

select 
	GeoRefId,
	en as Lang_EN,
	fr as Lang_FR,
	de as Lang_DE,
	es as Lang_ES,
	nl as Lang_NL,
	it as Lang_IT,
	el as Lang_EL,
	ja as Lang_JA,
	zh as Lang_ZH,
	ko as Lang_KO,
	id as Lang_ID,
	ar as Lang_AR,
	tr as Lang_TR,
	ms as Lang_MS,
	fi as Lang_FI,
	hi as Lang_HI,
	ru as Lang_RU,
	pt as Lang_PT,
	th as Lang_TH,
	ro as Lang_RO,
	sr as Lang_SR,
	sv as Lang_SV,
	hu as Lang_HU,
	he as Lang_HE,
	pl as Lang_PL,
	hk as Lang_HK,
	sm as Lang_SM,
	[to] as Lang_TO,
	cs as Lang_CS,
	da as Lang_DA,
	kk as Lang_KK,
	[is] as Lang_IS,
	vi as Lang_VI,
	di as Lang_DI,
	lk as Lang_LK
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
		smap.ConfigurationID = @configurationId and smap.IsDeleted=0 and
		lmap.ConfigurationID = @configurationId and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ([en], [fr], [de], [es], [nl], [it], [el], [ja], [zh], [ko], [id], [ar], [tr], [ms], [fi], 
		[hi], [ru], [pt], [th], [ro], [sr], [sv], [hu], [he], [pl], [hk], [vi], [sm], [to], [cs], [da], [is], [kk], [di], [tk],
		[uz], [bn], [mn], [bo], [az], [ep], [sp], [no], [lk]
	)
) as pivottable
order by GeoRefId

END

GO