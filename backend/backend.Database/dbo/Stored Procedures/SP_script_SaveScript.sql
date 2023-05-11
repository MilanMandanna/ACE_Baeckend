
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	this will return scriptdefId based on configurationId
-- Sample:EXEC [dbo].[SP_script_SaveScript] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_SaveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_script_SaveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_script_SaveScript]
        @configurationId INT
       
AS

BEGIN

       SELECT TOP 1 ScriptDefID FROM [cust].[tblScriptDefsMap] WHERE ConfigurationID=@configurationId 
END
GO
