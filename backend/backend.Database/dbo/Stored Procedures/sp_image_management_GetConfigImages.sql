IF OBJECT_ID('[dbo].[sp_image_management_GetConfigImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetConfigImages]
END
GO

CREATE PROC sp_image_management_GetConfigImages
@configurationId  INT,
@type INT
AS 
BEGIN
SELECT img.ImageId,img.ImageName,img.IsSelected,img.OriginalImagePath FROM dbo.config_tblImage(@configurationId) as img where img.ImageTypeId=@type
END

GO