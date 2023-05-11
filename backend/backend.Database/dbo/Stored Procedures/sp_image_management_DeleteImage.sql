IF OBJECT_ID('[dbo].[sp_image_management_DeleteImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_DeleteImage]
END
GO

CREATE PROC sp_image_management_DeleteImage
@imageId  INT,
@configurationId INT
AS 
BEGIN
	EXEC [SP_ConfigManagement_HandleDelete] @configurationId, 'tblImage', @imageId
END
GO