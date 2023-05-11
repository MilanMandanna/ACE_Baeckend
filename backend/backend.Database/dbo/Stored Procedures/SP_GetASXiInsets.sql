/****** Object:  StoredProcedure [dbo].[SP_GetASXiInsets]    Script Date: 9/19/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetASXiInsets]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetASXiInsets]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetASXiInsets]    Script Date: 9/19/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author:      Logeshwaran Sivaraj  
-- Create date: 9/19/2022  
-- Description: Retrieves all the Insets data 
--				based on the ConfigurationId  
-- Sample EXEC [dbo].[SP_GetASXiInsets] 12
-- =============================================  

CREATE PROCEDURE [dbo].[SP_GetASXiInsets]
    @ConfigurationId int 
	   
AS
BEGIN
    SELECT DISTINCT
    asxiInfo.*
    FROM dbo.config_tblASXiInset(@configurationId) AS asxiInfo
	ORDER BY asxiInfo.Zoom DESC
END
GO


