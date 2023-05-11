IF OBJECT_ID('[dbo].[sp_image_management_InsertImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_InsertImages]
END
GO

CREATE PROC sp_image_management_InsertImages
@configurationId INT,
@ImageId  INT,
@type INT,
@imageURL NVARCHAR(500),
@imageName NVARCHAR(500),
@guidFileName NVARCHAR(100)
AS 
BEGIN
INSERT INTO tblImage VALUES(@imageId,@imageName,@imageURL,@type,0,@guidFileName);
EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblImage', @imageId
END

GO