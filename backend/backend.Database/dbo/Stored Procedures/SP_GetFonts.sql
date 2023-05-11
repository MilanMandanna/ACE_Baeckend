
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Get the font based on configurationID
-- Sample: EXEC [dbo].[SP_GetFonts] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFonts]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFonts]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFonts]
        @configurationId INT
       
AS

BEGIN

                    SELECT DISTINCT tblFontFiles.*
                    ,
                    CASE WHEN dbo.tblFontFileSelectionMap.FontFileSelectionID IS NOT NULL THEN 1 ELSE 0 
                    END AS IsSelected 
                    FROM dbo.tblFontFiles INNER JOIN dbo.tblFontFilesMap ON dbo.tblFontFiles.FontFileID = dbo.tblFontFilesMap.FontFileID 
                    LEFT OUTER JOIN dbo.tblFontFileSelection ON dbo.tblFontFileSelection.FontFileID = dbo.tblFontFilesMap.FontFileID 
                    LEFT OUTER JOIN dbo.tblFontFileSelectionMap ON dbo.tblFontFileSelectionMap.FontFileSelectionID = dbo.tblFontFileSelection.FontFileSelectionID 
                    AND dbo.tblFontFileSelectionMap.ConfigurationID = dbo.tblFontFilesMap.ConfigurationID
                    WHERE dbo.tblFontFilesMap.ConfigurationID = @configurationId
END
GO