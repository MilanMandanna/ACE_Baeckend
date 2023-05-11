
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	updates global table
--Sample: EXEC [dbo].[SP_global_UpdateLanguageSetElements] 1,'en'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_UpdateLanguageSetElements]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_UpdateLanguageSetElements]
END
GO

CREATE PROCEDURE [dbo].[SP_global_UpdateLanguageSetElements]
        @configurationId INT,
		@languageCode NVARCHAR(Max)
		
       
AS

BEGIN
         DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int
		 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		
		  SET @CustomID = (SELECT  cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId )
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
         SET @sql=('UPDATE cust.tblGlobal 
                SET Global.modify(''insert <'+ @languageCode +'  clock= "eHour24" decimal= "os" grouping= "os" interactive_clock= "eHour24" interactive_units= "eMetric" units= "eMetric"/> 
                into (/global)[1]'') 
                WHERE cust.tblGlobal.CustomID = @updateKey')
	      EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
END
GO

