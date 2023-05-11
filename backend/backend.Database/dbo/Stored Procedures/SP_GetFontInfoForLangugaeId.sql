SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date: 2/22/2023
-- Description:	To get the font info for languages
-- EXEC [dbo].[SP_GetFontInfoForLangugaeId] 1,1,0
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetFontInfoForLangugaeId]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetFontInfoForLangugaeId]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFontInfoForLangugaeId]
    @languageId INT,
	@geoRefCatTypeId INT,
	@resolution INT
	
AS
BEGIN
        SELECT distinct tblfont.fontId,MarkerID,FaceName,Size,Color,ShadowColor,FontStyle FROM tblfontcategory INNER JOIN tblfont ON tblfontcategory.FontId = tblfont.FontId
        INNER JOIN tblfontfamily ON tblfont.FontFaceId=tblfontfamily.FontFaceId WHERE GeoRefIdCatTypeId=@geoRefCatTypeId AND
        Resolution=@resolution AND LanguageId=@languageId
END
GO

