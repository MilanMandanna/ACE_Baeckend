
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa,Brinda,Chindamada
-- Create date: 26/5/2022
-- Description:	Update the  language based on conditions
-- Sample: EXEC [dbo].[SP_global_UpdateLanguageSetElementsAttributes] 67,'fr','units','eMetric'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_UpdateLanguageSetElementsAttributes]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_global_UpdateLanguageSetElementsAttributes]

END

GO
CREATE PROCEDURE [dbo].[SP_global_UpdateLanguageSetElementsAttributes]
                        @configurationId INT,
						 @languagePrefix NVARCHAR(Max),
						 @name NVARCHAR( Max),
						 @value NVARCHAR (Max)
                       

AS

BEGIN        
         DECLARE @sql NVARCHAR(Max),@updateKey Int,@CustomID INT
		  DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		 SET @CustomID=(SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap  WHERE cust.tblGlobalMap.ConfigurationID = @configurationId)
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
         SET @sql=('UPDATE cust.tblGlobal 
                 SET Global.modify(''replace value of ('+ @languagePrefix +'/@'+ @name + ')[1] with "'+ @value+'"'') 
                  WHERE cust.tblGlobal.CustomID = @updateKey') 

				  print @sql
		 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
		 
END

GO
