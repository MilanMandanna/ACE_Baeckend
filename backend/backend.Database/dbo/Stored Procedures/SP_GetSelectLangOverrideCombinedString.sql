
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	returns the row based on combined string
-- Sample: EXEC [dbo].[SP_GetSelectLangOverrideCombinedString] 'English,French,Spanish,Simp_chinese'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetSelectLangOverrideCombinedString]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_GetSelectLangOverrideCombinedString]

END

GO

CREATE PROCEDURE [dbo].[SP_GetSelectLangOverrideCombinedString]
                       @combindedString NVARCHAR(250)
                      
                       

AS

BEGIN
               SELECT LOWER(dbo.tblLanguages.Name),[2LetterID_4xxx] FROM dbo.tblLanguages
               WHERE LOWER(dbo.tblLanguages.Name) IN(SELECT Item
               FROM dbo.SplitString(@combindedString, ',') )
			
END

GO