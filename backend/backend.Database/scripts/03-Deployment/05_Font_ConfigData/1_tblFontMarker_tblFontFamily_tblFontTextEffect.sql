IF NOT EXISTS (SELECT 1 FROM tblFontTextEffect)
BEGIN
	INSERT INTO tblFontTextEffect (FontTextEffectID, Name) VALUES 
	 (1,'Default'),
	 (2,'3D'),
	 (3,'Outline'),
	 (4,'Shadow');
END

IF NOT EXISTS (SELECT 1 FROM tblFontMarker)
BEGIN
	INSERT INTO tblFontMarker (MarkerId,Filename) VALUES 
	 (1,'square.png'),
	 (2,'whtcrcl.png'),
	 (3,'star.png'),
	 (4,'oceanmarker.png'),
	 (5,'departure.png'),
	 (6,'destination.png'),
	 (7,'waypoint.png');
	 INSERT INTO tblfontmarker (MarkerId,Filename) VALUES 
	 (1,'map_capital_state.png'),
	 (2,'map_city.png'),
	 (3,'map_capital_country.png'),
	 (4,'map_water.png'),
	 (5,'departure.png'),
	 (6,'destination.png'),
	 (7,'map_airport.png'),
	 (8,'map_city_POI.png'),
	 (9,'map_land_POI.png'),
	 (10,'map_water_POI.png'),
	 (11,'map_land.png');
END

IF NOT EXISTS (SELECT 1 FROM tblFontFamily)
BEGIN
	INSERT INTO tblFontFamily (FontFaceID, FaceName) VALUES 
	 (100,'Droid Sans'),
	 (101,'Droid Sans'),
	 (102,'Droid Sans'),
	 (103,'Droid Sans'),
	 (104,'Droid Sans'),
	 (105,'Droid Sans'),
	 (108,'Droid Sans'),
	 (109,'Droid Sans'),
	 (110,'Droid Sans'),
	 (112,'Droid Sans'),
	 (116,'Droid Sans'),
	 (126,'Droid Sans'),
	 (200,'Droid Sans'),
	 (201,'Droid Sans'),
	 (202,'Droid Sans'),
	 (203,'Droid Sans'),
	 (204,'Droid Sans'),
	 (205,'Droid Sans'),
	 (208,'Droid Sans'),
	 (209,'Droid Sans'),
	 (210,'Droid Sans'),
	 (212,'Droid Sans'),
	 (216,'Droid Sans'),
	 (226,'Droid Sans');
	INSERT INTO tblfontfamily (FontFaceId,FaceName,FileName) VALUES 
	(1000,'andalewtj','DroidSans.ttf');
	INSERT INTO tblfontfamily (FontFaceId,FaceName) VALUES 
	(100,'Utah,Utah MT'),
	(101,'Whitney-Medium,Whitney-Medium'),
	(102,'StoneSansITC,StoneSansITC MT'),
	(103,'Thorndale,Thorndale MT'),
	(104,'Cumberland,Cumberland AMT'),
	(105,'Helvetica,Helvetica'),
	(108,'Heisei,Heisei Maru Gothic W4 CP932'),
	(109,'Mhei_traditional,MHei Bold CP950'),
	(110,'HyGothic,HYGoThic'),
	(112,'Naskh,Naskh MT'),
	(116,'Devanagari,Devanagari MT'),
	(126,'Mhei_simple,Monotype Hei Bold CP936'),
	(200,'Utah MT'),
	(201,'Whitney-Medium'),
	(202,'StoneSansITC MT'),
	(203,'Thorndale MT'),
	(204,'Cumberland AMT'),
	(205,'Helvetica'),
	(208,'Heisei Maru Gothic W4 CP932'),
	(209,'MHei Bold CP950'),
	(210,'HYGoThic'),
	(212,'Naskh MT'),
	(216,'Devanagari MT'),
	(226,'Monotype Hei Bold CP936');
END