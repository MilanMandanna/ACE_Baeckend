
IF OBJECT_ID('[dbo].[sp_image_management_GetImageCount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetImageCount]
END
GO

CREATE PROC sp_image_management_GetImageCount
@configurationId INT
AS 
BEGIN

SELECT id,ImageType,count(B.ImageId) as imageCount FROM tblImageType A inner JOIN dbo.config_tblImage(@configurationId) as B
                     ON A.ID=B.ImageTypeId 
                     GROUP BY A.ID,ImageType
END

GO