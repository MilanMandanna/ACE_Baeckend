
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	Get the language based on congigurationId
-- Sample: EXEC [dbo].[SP_global_UpdateLanguage] 67
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_UpdateLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_UpdateLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_global_UpdateLanguage]
        @configurationId INT
       
AS

BEGIN

                    SELECT Lang.ID, Lang.LanguageID, Lang.Name, Lang.NativeName, Lang.Description, ISNULL(Lang.ISLatinScript, 0) AS ISLatinScript, Lang.Tier, 
					Lang.[2LetterID_4xxx],Lang.[3LetterID_4xxx], Lang.[2LetterID_ASXi], Lang.[3LetterID_ASXi],Lang.HorizontalOrder, 
					Lang.HorizontalScroll, Lang.VerticalOrder, Lang.VerticalScroll
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
                    WHERE  dbo.tblLanguagesMap.ConfigurationID = @configurationId
                    ORDER BY A.RowNum
END
GO
