IF OBJECT_ID('[dbo].[sp_image_management_UpdateResolutionSpecImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_UpdateResolutionSpecImage]
END
GO

CREATE PROC sp_image_management_UpdateResolutionSpecImage
@configurationId INT,
@imageId INT,
@imageURL NVARCHAR(500),
@resolutionId INT
AS 
BEGIN

UPDATE tblImageResSpec SET ImagePath=@imageURL WHERE ConfigurationID=@configurationId AND ImageId=@imageId AND ResolutionId=@resolutionId

END

GO