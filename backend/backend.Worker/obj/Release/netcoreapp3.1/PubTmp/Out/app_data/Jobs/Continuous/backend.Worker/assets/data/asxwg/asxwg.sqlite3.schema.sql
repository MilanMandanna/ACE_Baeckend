CREATE TABLE IF NOT EXISTS "tbwgcontent" (
  "WGContentId" int(11) NOT NULL DEFAULT '0',
  "GeoRefId" int(11) DEFAULT NULL,
  "TypeId" int(11) DEFAULT NULL,
  "ImageId" int(11) DEFAULT NULL,
  "TextId" int(11) DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS "tbwgimage" (
  "ImageId" int(11) NOT NULL DEFAULT '0',
  "Filename" varchar(255) DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS "tbwgtext" (
 "TextId" int(11) NOT NULL DEFAULT '0',
 "Text_EN" longtext,
 "Text_DE" longtext,
 "Text_ES" longtext,
 "Text_IT" longtext,
 "Text_EL" longtext,
 "Text_JA" longtext,
 "Text_KO" longtext,
 "Text_AR" longtext,
 "Text_MS" longtext,
 "Text_HI" longtext,
 "Text_RU" longtext,
 "Text_PT" longtext,
 "Text_RO" longtext,
 "Text_SR" longtext,
 "Text_HU" longtext,
 "Text_PL" longtext,
 "Text_HK" longtext,
 "Text_SM" longtext,
 "Text_TO" longtext,
 "Text_CS" longtext,
 "Text_DA" longtext,
 "Text_IS" longtext,
 "Text_EP" longtext,
 "Text_NO" longtext,
 "Text_TK" longtext
 );
CREATE TABLE IF NOT EXISTS "tbwgtype" (
  "TypeId" int(11) NOT NULL DEFAULT '0',
  "Description" varchar(255) DEFAULT NULL,
  "Layout" int(11) DEFAULT NUll,
  "ImageWidth" int(11) DEFAULT NUll,
  "ImageHeight" int(11) DEFAULT NUll
);

CREATE INDEX Idx1 ON tbwgcontent (WGContentId,GeoRefId);
CREATE INDEX Idx2 ON tbwgimage (ImageId);
CREATE INDEX Idx3 ON tbwgtype (TypeId);
CREATE INDEX Idx4 ON tbwgtext (TextId);

