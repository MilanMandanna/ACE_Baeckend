
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date:  5/24/2022
-- Description:	This SP will return DownloadPreferenceAssignment based on tailnumber and assestType
-- Sample: EXEC [dbo].[SP_GetAircraftDownloadPreferences]'xyz_deleted_637012045649249189',1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetAircraftDownloadPreferences]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetAircraftDownloadPreferences]
END
GO

CREATE PROCEDURE [dbo].[SP_GetAircraftDownloadPreferences]
		@tailNumber NVARCHAR(300),
        @assetType INT
AS

BEGIN

               SELECT dbo.DownloadPreferenceAssignment.* FROM dbo.DownloadPreferenceAssignment 
               INNER JOIN dbo.Aircraft ON dbo.DownloadPreferenceAssignment.AircraftId = dbo.Aircraft.Id 
               INNER JOIN dbo.DownloadPreference on dbo.DownloadPreferenceAssignment.DownloadPreferenceID = dbo.DownloadPreference.Id 
               WHERE dbo.Aircraft.TailNumber = @tailNumber AND dbo.DownloadPreference.AssetType = @assetType
END
GO

