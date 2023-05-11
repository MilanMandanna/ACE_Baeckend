
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	updates global table based on language and configuration id
--Sample: EXEC [dbo].[SP_global_SetDefaultLanguage] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_SetDefaultLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_SetDefaultLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_global_SetDefaultLanguage]
        @configurationId INT,
		@language NVARCHAR(100)
       
AS

BEGIN

    DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int
	DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
	SELECT @CustomID = CustomID FROM cust.tblGlobalMap WHERE ConfigurationID = @configurationId
	EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
    SET @sql=('UPDATE cust.tblGlobal  
                SET  Global.modify(''replace value of (/global/language_set/@default)[1] with "'+ @language +'" '') 
                WHERE cust.tblGlobal.CustomID IN 
                (SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap 
                WHERE cust.tblGlobalMap.ConfigurationID =@configurationId  AND CustomID = @updateKey)')
				
	 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
       
END
GO

