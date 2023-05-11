
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/24/2022
-- Description:	Get language list and default language 
-- Sample: EXEC [dbo].[SP_script_GetForcedLanguages] 67
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_GetForcedLanguages]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_script_GetForcedLanguages]
END
GO

CREATE PROCEDURE [dbo].[SP_script_GetForcedLanguages]
        @configurationId INT
       
AS

BEGIN

               SELECT Global.value('(/global/language_set)[1]', 'varchar(max)') AS lang_list,
               ISNULL(Nodes.item.value('(./@default)[1]','varchar(max)'),'') AS default_lang 
               FROM cust.tblGlobal b CROSS APPLY b.Global.nodes('/global/language_set') Nodes(item)
			   INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.ConfigurationID = tblGlobalMap.ConfigurationID 
               WHERE tblGlobalMap.ConfigurationID = @configurationId
END
GO
