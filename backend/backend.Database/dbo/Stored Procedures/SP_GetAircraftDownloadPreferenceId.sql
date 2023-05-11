
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date:  5/24/2022
-- Description:	This SP will return the rows from DownloadPreferenceAssignment table based on tail number and downloadPreferenceId
-- Sample: EXEC [dbo].[SP_GetAircraftDownloadPreferenceId] 'xyz_deleted_637012045649249189','C41ADFC5-CB74-41B7-A271-E0F7F0BC51C7'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetAircraftDownloadPreferenceId]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetAircraftDownloadPreferenceId]
END
GO

CREATE PROCEDURE [dbo].[SP_GetAircraftDownloadPreferenceId]
        @tailNumber NVARCHAR(100),
		@downloadPreferenceId  uniqueidentifier
       
AS

BEGIN

               SELECT dbo.DownloadPreferenceAssignment.* FROM dbo.DownloadPreferenceAssignment 
               INNER JOIN dbo.Aircraft ON dbo.DownloadPreferenceAssignment.AircraftId = dbo.Aircraft.Id 
               WHERE dbo.Aircraft.TailNumber = @tailNumber AND dbo.DownloadPreferenceAssignment.DownloadPreferenceId = @downloadPreferenceId
END
GO
