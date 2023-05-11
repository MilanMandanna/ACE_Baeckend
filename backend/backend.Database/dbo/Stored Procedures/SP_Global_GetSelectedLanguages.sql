-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns List of languaged selected for the given configuration
-- =============================================
IF OBJECT_ID('[cust].[SP_Global_GetSelectedLanguages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Global_GetSelectedLanguages]
END
GO

CREATE PROCEDURE [cust].[SP_Global_GetSelectedLanguages]
	@configurationId int
AS
BEGIN
    SELECT 
    A.RowNum,
    Lang.ID, Lang.LanguageID, Lang.Name, Lang.NativeName, Lang.Description, ISNULL(Lang.ISLatinScript, 0) AS ISLatinScript, Lang.Tier, Lang.[2LetterID_4xxx],
	Lang.[3LetterID_4xxx], Lang.[2LetterID_ASXi], Lang.[3LetterID_ASXi], Lang.HorizontalOrder, Lang.HorizontalScroll, Lang.VerticalOrder, Lang.VerticalScroll
    FROM
    (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as RowNum, value
    FROM STRING_SPLIT(
        (
        SELECT             
    UPPER(Global.value('(global/language_set)[1]', 'varchar(max)')) as language 
    FROM cust.tblGlobal INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID WHERE cust.tblGlobalMap.ConfigurationID = @configurationId
    )
    ,',')
    ) as A 
    INNER JOIN dbo.tblLanguages as Lang ON A.value LIKE CONCAT('%', 'E', UPPER(Lang.Name), '%')
    INNER JOIN dbo.tblLanguagesMap ON Lang.ID = dbo.tblLanguagesMap.LanguageID
    WHERE  dbo.tblLanguagesMap.ConfigurationID = @configurationId AND dbo.tblLanguagesMap.IsDeleted = 0
    ORDER BY A.RowNum
END