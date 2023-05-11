using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryWorldGuide
    {
		public static string GetExportASXi3DWGContent = @"
select
	tblWgContent.WGContentId,
	GeoRefId,
	TypeId,
	ImageId,
	TExtId
from tblWGContent
	inner join tblWGContentMap on tblWGContentMap.WGContentID = tblwgcontent.WGContentID
where
	tblWGContentMap.ConfigurationID = @configurationId";

		public static string GetExportASXi3DWGImage = @"
select
  -1 as ImageId,
  null as Filename
union
select
	tblwgImage.ImageId,
	Filename
from tblwgimage
	inner join tblwgimagemap on tblwgimagemap.ImageID = tblwgimage.ImageID
where
	tblwgimagemap.ConfigurationID = @configurationId";

		public static string SQL_GetExportASXi3DWGText = @"
select 
	[TextID],
	[Text_EN],
	[Text_FR],
	[Text_DE],
	[Text_ES],
	[Text_NL],
	[Text_IT],
	[Text_EL],
	[Text_JA],
	[Text_ZH],
	[Text_KO],
	[Text_ID],
	[Text_AR],
	[Text_TR],
	[Text_MS],
	[Text_FI],
	[Text_HI],
	[Text_RU],
	[Text_PT],
	[Text_TH],
	[Text_RO],
	[Text_SR],
	[Text_SV],
	[Text_HU],
	[Text_HE],
	[Text_PL],
	[Text_HK],
	[Text_SM],
	[Text_TO],
	[Text_CS],
	[Text_DA],
	[Text_IS],
	[Text_VI]
from tblwgtext
	inner join tblwgtextmap on tblwgtextmap.WGtextID = tblwgtext.WGtextID
where
	tblwgtextmap.ConfigurationID = @configurationId
order by textid";

		public static string SQL_GetExportASXi3DWGType = @"
select 
	TypeId,
	Description,
	Layout,
	ImageWidth,
	ImageHeight
from tblwgtype
	inner join tblWGTypeMap on tblwgtypemap.WGTypeID = tblwgtype.WGTypeID
where
	tblwgtypemap.ConfigurationID = @configurationId
order by TypeId";

		public static string SQL_GetExportASXi3DWGCities = @"
select 
	city_id,
	georefid
from tblwgwcities
	inner join tblwgwcitiesMap on tblwgwcitiesMap.CityID = tblwgwcities.city_id
where
	tblwgwcitiesMap.ConfigurationID = @configurationId
order by city_id";

	}
}
