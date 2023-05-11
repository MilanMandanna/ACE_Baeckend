
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada
-- Create date:  5/25/2022
-- Description:	This SP will return FontFileSelectionId based on FontFileID
-- Sample: EXEC [dbo].[SP_GetFontSelectionIdForFont] 2
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFontSelectionIdForFont]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFontSelectionIdForFont]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFontSelectionIdForFont]
        @fontFileId INT
       
AS

BEGIN

       SELECT dbo.tblFontFileSelection.* FROM dbo.tblFontFileSelection  WHERE dbo.tblFontFileSelection.FontFileID =  @fontFileId
END
GO

