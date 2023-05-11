IF OBJECT_ID('[dbo].[sp_image_management_RenameFile]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_RenameFile]
END
GO

CREATE PROC sp_image_management_RenameFile
@imageId INT,
@type INT,
@fileName NVARCHAR(500)
AS 
BEGIN

UPDATE tblImage SET ImageName=@fileName WHERE ImageId=@imageId AND ImageTypeId=@type
END
GO