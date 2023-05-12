CREATE TABLE IF NOT EXISTS "tbgeorefidcategorytype" (
  "GeoRefIdCatTypeId" int(11) NOT NULL DEFAULT '0',
  "Description" varchar(255) DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS "tblanguage" (
  "LanguageID" int(11) NOT NULL DEFAULT '0',
  "Name" varchar(30) DEFAULT NULL,
  "TwoLetterID" varchar(2) DEFAULT NULL,
  "ThreeLetterID" varchar(3) DEFAULT NULL,
  "HorizontalOrder" int(11) DEFAULT NULL,
  "HorizontalScroll" int(11) DEFAULT NULL,
  "VerticalOrder" int(11) DEFAULT NULL,
  "VerticalScroll" int(11) DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS "tbfontfamily" (
  "FontFaceId" int(11) NOT NULL DEFAULT '0',
  "FaceName" varchar(255) DEFAULT NULL,
  "FileName" varchar(255) DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS "tbfontmarker" (
  "MarkerId" int(11) NOT NULL DEFAULT '0',
  "Filename" varchar(255) DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS "tbfontcategory" (
  "GeoRefIdCatTypeId" int(11) NOT NULL DEFAULT '0',
  "LanguageId" int(11) NOT NULL DEFAULT '0',
  "FontId" int(11) DEFAULT NULL,
  "MarkerId" int(11) DEFAULT NULL,
  "IMarkerId" int(11) DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS "tbfont" (
  "FontId" int(11) NOT NULL DEFAULT '0',
  "Description" varchar(255) DEFAULT NULL,
  "Size" int(11) DEFAULT NULL,
  "Color" varchar(8) DEFAULT NULL,
  "ShadowColor" varchar(8) DEFAULT NULL,
  "FontFaceId" int(11) DEFAULT NULL,
  "FontStyle" int(11) DEFAULT NULL
);
-- need to get this table with all the languages
CREATE TABLE IF NOT EXISTS "tbinfospelling" (
  "InfoId" int(11) NOT NULL DEFAULT '0'
);
CREATE TABLE IF NOT EXISTS "tbcountry" (
  "CountryId" int(11) NOT NULL DEFAULT '0'
);
CREATE TABLE IF NOT EXISTS "tbregion" (
  "RegionId" int(11) NOT NULL DEFAULT '0'
);
CREATE TABLE IF NOT EXISTS "tbgeorefid" (
  "GeoRefId" int(11) NOT NULL DEFAULT '0',
  "GeoRefIdCatTypeId" int(11) NOT NULL DEFAULT '1',
  "RegionId" int(11) DEFAULT NULL,
  "CountryId" int(11) DEFAULT NULL,
  "Elevation" int(11) DEFAULT '0',
  "Population" int(11) DEFAULT '0',
  "LayerDisplay" int(11) DEFAULT '1',
  "ISearch" tinyint(1) DEFAULT '0',
  "RLIPOI" tinyint(1) DEFAULT '0',
  "IPOI" tinyint(1) DEFAULT '0',
  "WCPOI" tinyint(1) DEFAULT '0',
  "MakkahPOI" tinyint(1) DEFAULT NULL,
  "ClosestPOI" tinyint(1) DEFAULT '0',
  "Lat" double DEFAULT NULL,
  "Lon" double DEFAULT NULL,
  "Inclusion" int(11) NOT NULL DEFAULT '0'
);
CREATE TABLE IF NOT EXISTS "tbairportinfo" (
  "FourLetId" varchar(4) NOT NULL DEFAULT '',
  "ThreeLetId" varchar(3) DEFAULT NULL,
  "Lat" double NOT NULL DEFAULT '0',
  "Lon" double NOT NULL DEFAULT '0',
  "PointGeoRefId" int(11) DEFAULT NULL,
  "AirportGeoRefId" int(11) DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS "tbtzstrip" (
  "GeoRefId" int(11) NOT NULL,
  "TimeZoneStrip" int(11) DEFAULT NULL
);
CREATE INDEX Idx1 ON tbgeorefid (GeoRefId);
CREATE INDEX Idx2 ON tbfontcategory (GeoRefIdCatTypeId , LanguageId);
CREATE INDEX Idx3 ON tbgeorefidcategorytype (GeoRefIdCatTypeId);
CREATE INDEX Idx4 ON tbtzstrip (TimeZoneStrip);
CREATE INDEX Idx5 ON tbfontfamily (FontFaceId);
CREATE INDEX Idx6 ON tbfont (FontId);
CREATE INDEX Idx7 ON tbgeorefid (Lat);
CREATE INDEX Idx8 ON tbgeorefid (Lon);
CREATE INDEX Idx9 ON tbgeorefid (WCPOI);
CREATE INDEX Idx10 ON tbgeorefid (MakkahPOI);
CREATE INDEX Idx11 ON tbgeorefid(CountryId);
CREATE INDEX Idx12 ON tbcountry(CountryId);
CREATE INDEX Idx13 ON tbgeorefid(RegionId);
CREATE INDEX Idx14 ON tbgeorefid(Inclusion);
