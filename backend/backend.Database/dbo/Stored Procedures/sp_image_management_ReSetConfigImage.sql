
IF OBJECT_ID('[dbo].[sp_image_management_ReSetConfigImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_ReSetConfigImage]
END
GO

CREATE PROC sp_image_management_ReSetConfigImage
@configurationId INT,
@type INT
AS 
BEGIN

    UPDATE img
    SET img.IsSelected = 0
    FROM 
    dbo.config_tblImage(@configurationId) as img
    WHERE img.imageTypeId = @type and img.IsSelected = 1

END

GO