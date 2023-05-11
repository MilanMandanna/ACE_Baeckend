

IF OBJECT_ID('[dbo].[sp_image_management_SetConfigImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_SetConfigImage]
END
GO

CREATE PROC sp_image_management_SetConfigImage
@configurationId INT,
@type INT,
@imageId INT
AS 
BEGIN

    UPDATE img
    SET img.IsSelected = 1
    FROM 
    dbo.config_tblImage(@configurationId) as img
    WHERE img.imageTypeId = @type and img.ImageId = @imageId

END

GO