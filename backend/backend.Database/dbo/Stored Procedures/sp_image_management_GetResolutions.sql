IF OBJECT_ID('[dbo].[sp_image_management_GetResolutions]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetResolutions]
END
GO

CREATE PROC sp_image_management_GetResolutions
AS 
BEGIN
SELECT ID,resolution FROM tblImageres
END

GO