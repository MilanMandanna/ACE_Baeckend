
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	This query will update cust.tblGlobal based on configurationId and language code
-- Sample: EXEC [dbo].[SP_GlobalRemoveLanguage] 1,'EN'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GlobalRemoveLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GlobalRemoveLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_GlobalRemoveLanguage]
        @configurationId INT,
		@languageCode NVARCHAR(Max)
       
AS

BEGIN
       DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int
	    DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
        SET @CustomID = (SELECT  cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId)
	   EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
	   print @updateKey
       SET @sql= ('UPDATE cust.tblGlobal 
                SET Global.modify(''delete (/global/' +@languageCode+')[1]'') 
                WHERE cust.tblGlobal.CustomID = @updateKey')
	   EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
END
GO