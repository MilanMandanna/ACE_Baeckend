
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	get the language list and default language
-- Sample: EXEC [dbo].[SP_GetLanguagesOverride] 110
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetLanguagesOverride]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetLanguagesOverride]
END
GO

CREATE PROCEDURE [dbo].[SP_GetLanguagesOverride]
              @configurationId INT
     
       
AS

BEGIN

	  SELECT Global.value('(/global/language_set)[1]', 'varchar(max)') AS lang_list,
                        ISNULL(Nodes.item.value('(./@default)[1]','varchar(max)'),'') AS default_lang 
                        FROM cust.tblGlobal b 
                        CROSS APPLY b.Global.nodes('/global/language_set') Nodes(item) 
						INNER JOIN cust.tblGlobalMap c ON c.CustomID = b.CustomID 
                        WHERE c.ConfigurationID = @configurationId

END
GO

