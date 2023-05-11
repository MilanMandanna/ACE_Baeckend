
IF OBJECT_ID('[dbo].[sp_image_management_GetImageDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetImageDetails]
END
GO
CREATE PROC sp_image_management_GetImageDetails
@ImageId  INT,
@configurationId INT
AS 
BEGIN
SELECT img.ImageName,img.OriginalImagePath FROM dbo.config_tblImage(@configurationId) as img WHERE img.ImageId=@ImageId
END

GO