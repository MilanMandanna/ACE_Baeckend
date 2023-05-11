IF NOT EXISTS (SELECT 1 FROM tblWGType)
BEGIN
	INSERT INTO tblwgtype (TypeId,Description,Layout,ImageWidth,ImageHeight) VALUES 
 (1,'Overview',NULL,NULL,NULL),
 (2,'Slide Show',NULL,NULL,NULL),
 (3,'Features',NULL,NULL,NULL),
 (4,'Sights',NULL,NULL,NULL),
 (5,'Stats',NULL,NULL,NULL);
END