using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryFonts
    {
		public static string SQL_GetExportASXi3DFonts = @"
select
	tblFont.FontId,
	Description,
	Size,
	Color,ShadowColor,
	FontFaceId,
	FontStyle,
	PxSize,TextEffectId
from tblFont
	inner join tblFontMap on tblFontMap.FontID = tblFont.ID
where
	tblFontMap.ConfigurationID = @configurationId";

		public static string SQL_GetExportASXi3DFontCategory = @"
select
	GeoRefIdCatTypeId,
	LanguageId,
	FontId,
	MarkerId,
	IMarkerId,
	Resolution,
	SphereFontId,
	AtlasMarkerId,
	SphereMarkerId
from tblFontCategory
	inner join tblFontCategoryMap on tblFontCategoryMap.FontCategoryID = tblFontCategory.FontCategoryID
where
	tblFontCategoryMap.ConfigurationID = @configurationId";

		public static string SQL_GetExportASXi3DFontDefaultCategory = @"
select
	GeoRefIdCatTypeId,
	FontId,
	MarkerId,
	Resolution,
	SphereFontId,
	AtlasMarkerId,
	SphereMarkerId
from tblFontDefaultCategory
	inner join tblFontDefaultCategoryMap on tblFontDefaultCategoryMap.FontDefaultCategoryID = tblFontDefaultCategory.FontDefaultCategoryID
where
	tblFontDefaultCategoryMap.ConfigurationID = @configurationId";

		public static string SQL_GetExportASXi3DFontFamily = @"
select
	FontFaceId,
	FaceName,
	FileName
from tblFontFamily
	inner join tblFontFamilyMap on tblFontFamilyMap.FontFamilyID = tblFontFamily.FontFamilyId
where
	tblFontFamilyMap.ConfigurationID = @configurationId";

		public static string SQL_GetExportASXi3DFontMarker = @"
select
	MarkerId,
	Filename
from tblFontMarker
	inner join tblFontMarkerMap on tblFontMarkerMap.FontMarkerID = tblFontMarker.FontMarkerID
where
	tblFontMarkerMap.ConfigurationID = @configurationId";

		public static string SQL_GetExportASXi3DFontTextEffect = @"
select
	Name
from tblFontTextEffect
	inner join tblFontTextEffectMap on tblFontTextEffectMap.FontTextEffectID = tblFontTextEffect.FontTextEffectID
where
	tblFontTextEffectMap.ConfigurationID = @configurationId";

		public static string SQL_GetExportCESHTSEFonts = @"
select
	tblFont.FontId,
	Description,
	Size,
	PxSize,
	Color,
	ShadowColor,
	FontFaceId,
	FontStyle,
	TextEffectId
from tblFont
	inner join tblfontmap on tblfontmap.FontID = tblFont.FontId
where
	tblfontmap.ConfigurationID = @configurationId
order by tblFont.fontid";

		public static string SQL_GetExportCESHTSEFontCategories = @"
select
	GeoRefIdCatTypeId,
	HTSE_Resolution as Resolution,
	LanguageId,
	FontId,
	HTSE_SphereFontId as SphereFontId,
	MarkerId,
	HTSE_AtlasMarkerId as AtlasMarkerId,
	HTSE_SphereMarkerId as SphereMarkerId
from tblFontCategory
	inner join tblFontCategoryMap as fcmap on fcmap.FontCategoryID = tblFontCategory.FontCategoryID
where
	fcmap.ConfigurationID = @configurationId
order by tblFontCategory.FontCategoryID";

		public static string SQL_GetExportCESHTSEFontDefaultCategories = @"
select
	GeoRefIdCatTypeId,
	Resolution,
	FontId,
	SphereFontId,
	MarkerId,
	AtlasMarkerId,
	SphereMarkerId
from tblFontDefaultCategory
	inner join tblFontDefaultCategoryMap as fcmap on fcmap.FontDefaultCategoryID = tblFontDefaultCategory.FontDefaultCategoryID
where
	fcmap.ConfigurationID = @configurationId
order by tblFontDefaultCategory.FontDefaultCategoryID";

		public static string SQL_GetExportCESHTSEFontFamily = @"
select
	FontFaceId,
	FaceName as Name
from tblfontfamily
	inner join tblFontFamilyMap as fmap on fmap.FontFamilyID = tblfontfamily.FontFamilyID
where
	fmap.ConfigurationID = @configurationId
order by fontfaceid";

	}
}
