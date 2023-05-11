
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	This SP will give the number of column name based on configurationID from table fontfileselectionMap
-- Sample: EXEC [dbo].[SP_GetFontSelectionMappingCount] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFontSelectionMappingCount]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFontSelectionMappingCount]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFontSelectionMappingCount]
        @configurationId INT
       
AS

BEGIN

       select count(*) from dbo.tblFontFileSelectionMap WHERE dbo.tblFontFileSelectionMap.ConfigurationID =  @configurationId
END
GO

