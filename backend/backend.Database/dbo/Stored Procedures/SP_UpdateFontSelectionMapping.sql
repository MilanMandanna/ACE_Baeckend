
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/30/2022
-- Description:	updates table fontfileselectionmap based on condition
-- Sample: EXEC [dbo].[SP_UpdateFontSelectionMapping] 3,2,'4dbed025-b15f-4760-b925-34076d13a10a',1
-- =============================================
IF OBJECT_ID('[dbo].[SP_UpdateFontSelectionMapping]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_UpdateFontSelectionMapping]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateFontSelectionMapping]
		@previousFontFileSelectionID INT,
        @fontFileSelectionID INT,
		@lastModifiedBy NVARCHAR(300),
		@configurationId INT
AS

BEGIN

      DECLARE @updateKey int
      EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblFontFileSelection',@fontFileSelectionID,@updateKey out
      UPDATE dbo.tblFontFileSelectionMap SET PreviousFontFileSelectionID = @previousFontFileSelectionID,FontFileSelectionID = @updateKey,
      LastModifiedBy = @lastModifiedBy  WHERE dbo.tblFontFileSelectionMap.ConfigurationID =  @configurationId 
	 
END
GO