
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Get languages based on configurationId
-- Sample: EXEC [dbo].[SP_global_GetAllLanguages] 
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_GetAllLanguages]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_GetAllLanguages]
END
GO

CREATE PROCEDURE [dbo].[SP_global_GetAllLanguages]
       
AS

BEGIN    
		select distinct ID,LanguageID,Name,NativeName,Description,(ISNULL(ISLatinScript, 0)) AS ISLatinScript,Tier,[2LetterID_4xxx],[3LetterID_4xxx],[2LetterID_ASXi],
		[3LetterID_ASXi],HorizontalOrder,HorizontalScroll,VerticalOrder,VerticalScroll
		from tblLanguages 
	
END
GO

