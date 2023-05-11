GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXi3DLanguages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXi3DLanguages]
END
GO
CREATE PROC sp_GetExportASXi3DLanguages
@configurationId INT
AS 
BEGIN

select 
	tblLanguages.LanguageID,
	tblLanguages.Name,
	tblLanguages.[2LetterID_ASXi] as TwoLetterID,
	tblLanguages.[3LetterID_ASXi] as ThreeLetterID,
	HorizontalOrder,
	HorizontalScroll,
	VerticalOrder,
	VerticalScroll
from tbllanguages
	inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.ID
where
	lmap.ConfigurationID = @configurationId and lmap.IsDeleted=0
order by tbllanguages.languageid

END

GO