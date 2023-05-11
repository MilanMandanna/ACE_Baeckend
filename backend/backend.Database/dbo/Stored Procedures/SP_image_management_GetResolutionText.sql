IF OBJECT_ID('[dbo].[sp_image_management_GetResolutionText]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetResolutionText]
END
GO

CREATE PROC sp_image_management_GetResolutionText
@resolutionId INT

AS 
BEGIN
	IF (@resolutionId = -1)
		SELECT resolution FROM tblImageres WHERE IsDefault=1
	ELSE 
		SELECT resolution FROM tblImageres WHERE ID=@resolutionId
END
GO