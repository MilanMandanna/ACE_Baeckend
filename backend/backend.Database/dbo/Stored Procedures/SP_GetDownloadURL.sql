SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 5/24/2022
-- Description:	Procedure to retrieve the download URL
-- Sample EXEC [dbo].[SP_GetDownloadURL] 18, 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetDownloadURL]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetDownloadURL]
END
GO

CREATE PROCEDURE [dbo].[SP_GetDownloadURL]
	@configurationId INT,
	@taskId NVARCHAR(500)
AS
BEGIN
	SELECT Path AS downloadURL FROM tblConfigurationComponents CC
	INNER JOIN tblConfigurationComponentsMap CCM
	ON CC.[ConfigurationComponentID ] = CCM.ConfigurationComponentID AND CCM.ConfigurationID = @configurationId AND CC.[ConfigurationComponentID ] = @taskId
END
GO