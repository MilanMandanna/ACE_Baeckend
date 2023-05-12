CREATE TABLE IF NOT EXISTS "tbairportinfo" (
  "FourLetId" varchar(4) NOT NULL DEFAULT '',
  "ThreeLetId" varchar(3) DEFAULT NULL,
  "Lat" double NOT NULL DEFAULT '0',
  "Lon" double NOT NULL DEFAULT '0',
  "PointGeoRefId" int(11) DEFAULT NULL,
  "AirportGeoRefId" int(11) DEFAULT NULL
);