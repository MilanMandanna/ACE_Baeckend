
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda 
-- Create date: 5/6/22
-- Description:	Updates the row based on configurationId and language
-- Sample: EXEC [dbo].[SP_Globalconfig_Respo] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Globalconfig_Respo]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_Globalconfig_Respo]
END
GO

CREATE PROCEDURE [dbo].[SP_Globalconfig_Respo]
        @ConfigurationID INT,
		@languageSetToUpdate VARCHAR(Max)
       
AS

BEGIN
		DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int
		DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
        SET @sql='UPDATE cust.tblGlobal SET  
                 Global.modify(''replace value of (/global/language_set/text())[1] with "' +@languageSetToUpdate+'" '')
                WHERE cust.tblGlobal.CustomID IN 
                (SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId )'
	    EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
END
GO