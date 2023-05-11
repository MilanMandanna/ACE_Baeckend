
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	This SP will return id,AssetType,Title based on given name
-- Sample: EXEC [dbo].[SP_GetByNameForDownloadPreference] 'Episode'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetByNameForDownloadPreference]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetByNameForDownloadPreference]
END
GO

CREATE PROCEDURE [dbo].[SP_GetByNameForDownloadPreference]
        @name NVARCHAR(100)
       
AS

BEGIN

      SELECT * FROM dbo.DownloadPreference WHERE dbo.DownloadPreference.Name = @name
END
GO

