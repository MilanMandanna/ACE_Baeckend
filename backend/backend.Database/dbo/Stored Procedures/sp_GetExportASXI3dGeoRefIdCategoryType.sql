GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dGeoRefIdCategoryType]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dGeoRefIdCategoryType]
END
GO
CREATE PROC sp_GetExportASXI3dGeoRefIdCategoryType
AS
BEGIN

select 
	GeoRefCategoryTypeID_ASXIAndroid as GeoRefIdCatTypeId,
	Description
from tblCategoryType
where
	GeoRefCategoryTypeID_ASXIAndroid is not null
order by GeoRefCategoryTypeID_ASXIAndroid

END

GO