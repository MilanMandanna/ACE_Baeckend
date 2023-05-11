
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date:  5/25/2022
-- Description:	This Sp will returns the value based on name,configId and language prefix
-- Sample: EXEC [dbo].[SP_global_GetSelectLanguage] 'ENGLISH',1,'EN'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_GetSelectLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_GetSelectLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_global_GetSelectLanguage]
        @name NVARCHAR(100),
		@configurationId  INT,
		@langprefix NVARCHAR(100) 
       
AS

BEGIN
		
       DECLARE @sql NVARCHAR(Max), @params NVARCHAR(4000) = '@inputName VARCHAR(255),@configurationId Int' 
     SET @sql =N'SELECT CASE WHEN UPPER(Global.value(''(global/language_set/@default)[1]'', ''varchar(max)'')) = @inputName THEN 1 ELSE 0
       END AS IsDefault, 
	   ISNULL(Global.value(''(' + @langprefix + '/@clock)[1]'', ''varchar(max)''),''eHour24'') as Clock, 
       ISNULL(Global.value(''(' + @langprefix + '/@decimal)[1]'' , ''varchar(max)''),''os'') as Decimal, 
       ISNULL(Global.value(''(' + @langprefix + '/@grouping)[1]'', ''varchar(max)''),''os'') as Grouping, 
       ISNULL(Global.value(''(' + @langprefix + '/@interactive_clock)[1]'', ''varchar(max)''),''eHour24'') as InteractiveClock,
       ISNULL(Global.value(''(' + @langprefix + '/@interactive_units)[1]'', ''varchar(max)''),''eMetric'') as InteractiveUnits,
       ISNULL(Global.value(''(' + @langprefix + '/@units)[1]'', ''varchar(max)''),''eMetric'') as Units 
       FROM cust.tblGlobal 
       INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID 
       WHERE cust.tblGlobalMap.ConfigurationID =  @configurationId '
	   
	   EXEC SP_EXECUTESQL @sql ,@params,@inputName = @name,@configurationId = @configurationId
		
END
GO
