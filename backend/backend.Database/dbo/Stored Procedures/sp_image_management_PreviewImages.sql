IF OBJECT_ID('[dbo].[sp_image_management_PreviewImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_PreviewImages]
END
GO

CREATE PROC sp_image_management_PreviewImages
@configurationId INT,
@imageId INT
AS 
BEGIN

SELECT ResolutionId,ImagePath,res.IsDefault,res.resolution,res.Description FROM tblImageResSpec map RIGHT JOIN tblImageres res 
                        ON map.resolutionId=res.ID WHERE ImageId=@imageId AND ConfigurationID=@configurationId

END

GO