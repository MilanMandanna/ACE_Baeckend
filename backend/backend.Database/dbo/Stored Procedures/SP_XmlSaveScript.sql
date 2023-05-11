
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	inserting xml into tblscriptdefs
-- sample: EXEC [dbo].[SP_XmlSaveScript]'ENGLISH' 
-- =============================================

IF OBJECT_ID('[dbo].[SP_XmlSaveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_XmlSaveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_XmlSaveScript]
        @xml NVARCHAR(100)
       
AS

BEGIN

       INSERT INTO [cust].[tblScriptDefs] VALUES(@xml)
	   SELECT SCOPE_IDENTITY()
	   
END

GO