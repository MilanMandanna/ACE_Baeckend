
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	it will insert 
-- Sample: EXEC [dbo].[SP_XmlInsertSaveScript] 36,34
-- =============================================

IF OBJECT_ID('[dbo].[SP_XmlInsertSaveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_XmlInsertSaveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_XmlInsertSaveScript]
        @configId INT,
		@scriptDefId  INT
       
AS

BEGIN
        
		  
		   EXEC dbo.SP_ConfigManagement_HandleAdd @configId, 'tblScriptDefs',@ScriptDefID
		
		  

    
END
GO
