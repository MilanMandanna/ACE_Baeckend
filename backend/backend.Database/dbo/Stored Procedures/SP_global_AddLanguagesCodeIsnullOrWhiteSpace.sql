
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 5/27/2022
-- Description:	updates table global based on language and configid
-- Sample: EXEC  [dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]
END
GO

CREATE PROCEDURE [dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]
	    @configurationId INT,
        @languageSetToUpdate NVARCHAR(Max)
		
       
AS

BEGIN 
            DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int, @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		  SELECT  @CustomID=ISNULL(cust.tblGlobalMap.CustomID,0) FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId 
		    
			IF @CustomID!=0
			BEGIN
				EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
		     
			   SET @sql=('UPDATE cust.tblGlobal SET 
					Global.modify(''replace value of (/global/language_set/text())[1] with " '+ @languageSetToUpdate +'" '') 
					WHERE cust.tblGlobal.CustomID IN 
					(SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId  AND CustomID = @updateKey )') 
				 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey 
			 END
			 ELSE
			 BEGIN
				 DECLARE @langXML NVARCHAR(MAX)='<global><language_set default="'+@languageSetToUpdate+'">'+@languageSetToUpdate+'</language_set>
									  </global>'
				INSERT INTO cust.tblGlobal (Global) VALUES(@langXML);
				DECLARE @latestCustomId int=(SELECT SCOPE_IDENTITY());
				print @latestCustomId
				EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId ,'tblGlobal',@latestCustomId
			END
END
GO
