
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	Returns number of rows from DownloadPreference table based on assetType
-- Sample: EXEC [dbo].[SP_GetAllDownloadPreference] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetAllDownloadPreference]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetAllDownloadPreference]
END
GO

CREATE PROCEDURE [dbo].[SP_GetAllDownloadPreference]
        @assetType INT
       
AS

BEGIN

       SELECT * FROM dbo.DownloadPreference WHERE dbo.DownloadPreference.AssetType = @assetType
END
GO

