
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	Get the languages based on configurationId
-- Sample:EXEC [dbo].[SP_global_AddLanguages] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_AddLanguages]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_AddLanguages]
END
GO

CREATE PROCEDURE [dbo].[SP_global_AddLanguages]
        @configurationId INT
       
AS

BEGIN

                SELECT Global.value('(global/language_set)[1]', 'varchar(max)')
                FROM 
                cust.tblGlobal INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID 
                WHERE cust.tblGlobalMap.ConfigurationID = @configurationId 
END
GO
