-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the list of placename with spelling info for given config id and geo ref id
-- =============================================
GO
IF OBJECT_ID('[dbo].[sp_placenames_getplacenamespelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getplacenamespelling]
END
GO
CREATE PROC sp_placenames_getplacenamespelling
@geoRefId INT,
@configurationId INT
AS
BEGIN

select spel.SpellingID,lang.Name,spel.UnicodeStr from tblSpelling spel 
INNER JOIN tblSpellingMap spellMap on spellMap.SpellingID=spel.SpellingID 
INNER JOIN tblLanguages lang ON lang.LanguageID=spel.LanguageID
INNER JOIN tblLanguagesMap langMap on langMap.LanguageID=lang.LanguageID 
WHERE spel.GeoRefID=@geoRefId AND spellMap.ConfigurationID=@configurationId AND spellMap.IsDeleted=0 
AND langMap.ConfigurationID=@configurationId AND langMap.IsDeleted=0

END

GO