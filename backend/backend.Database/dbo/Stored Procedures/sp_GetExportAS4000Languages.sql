GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000Languages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000Languages]
END
GO
CREATE PROC sp_GetExportAS4000Languages
@configurationId INT
AS 
BEGIN

select
	tblLanguages.LanguageID,
	Name,
	tblLanguages.[2LetterID_4xxx] as '2LetterID',
	tblLanguages.[3LetterID_4xxx] as '3LetterID',
	HorizontalOrder,
	HorizontalScroll,
	VerticalOrder,
	VerticalScroll,
	case 
		when tblLanguages.LanguageID = 1 then 'ENGLISH'
		else 'METRIC'
	end as UnitType,
	case
		when tblLanguages.LanguageID = 1 then 'HOUR12'
		else 'HOUR24'
	end as TimeType
from tblLanguages
	inner join tblLanguagesMap as lmap on lmap.LanguageID = tblLanguages.ID
where
	lmap.ConfigurationID = @configurationId and lmap.IsDeleted=0
order by tblLanguages.LanguageID

END

GO