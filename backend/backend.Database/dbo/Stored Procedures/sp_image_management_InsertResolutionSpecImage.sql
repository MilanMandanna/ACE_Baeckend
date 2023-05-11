IF OBJECT_ID('[dbo].[sp_image_management_InsertResolutionSpecImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_InsertResolutionSpecImage]
END
GO
CREATE PROC sp_image_management_InsertResolutionSpecImage
@configurationId INT,
@ImageId  INT,
@resolutionId INT,
@imageURL NVARCHAR(500)
AS 
BEGIN
INSERT INTO tblImageResSpec VALUES(@configurationId,@imageId,@resolutionId,@imageURL)
END

GO