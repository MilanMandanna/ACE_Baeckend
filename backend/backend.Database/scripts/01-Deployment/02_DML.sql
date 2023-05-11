IF NOT EXISTS (SELECT ImageType FROM tblImageType WHERE ImageType='Logo')
INSERT INTO tblImageType VALUES('Logo','Image Type for Logo')

IF NOT EXISTS (SELECT ImageType FROM tblImageType WHERE ImageType='Splash')
INSERT INTO tblImageType VALUES('Splash','Image Type for Splash')

IF NOT EXISTS (SELECT ImageType FROM tblImageType WHERE ImageType='Script')
INSERT INTO tblImageType VALUES('Script','Image Type for Script')

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='1280x800')
INSERT INTO tblImageres SELECT '1280x800',1,'MOBILE DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='1334x750')
INSERT INTO tblImageres SELECT '1334x750',0,'TAB DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='1920x1080')
INSERT INTO tblImageres SELECT '1920x1080',0,'MOBILE DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='2048x1536')
INSERT INTO tblImageres SELECT '2048x1536',0,'TAB DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='2224x1668')
INSERT INTO tblImageres SELECT '2224x1668',0,'MOBILE DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='2280x1080')
INSERT INTO tblImageres SELECT '2280x1080',0,'TAB DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='2388x1668')
INSERT INTO tblImageres SELECT '2388x1668',0,'MOBILE DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='2560x1600')
INSERT INTO tblImageres SELECT '2560x1600',0,'TAB DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='2732x2048')
INSERT INTO tblImageres SELECT '2732x2048',0,'MOBILE DISPLAY'

IF NOT EXISTS (SELECT resolution FROM tblImageres WHERE resolution='3200x1440')
INSERT INTO tblImageres SELECT '3200x1440',0,'TAB DISPLAY'

UPDATE tblImageres SET IsDefault=1 WHERE ID=3
UPDATE tblImageres SET IsDefault=0 WHERE ID=1;
UPDATE tblImageres SET Description='Various Android devices' WHERE ID IN(10,8,6,1)
UPDATE tblImageres SET Description='Full HD, Various Android Devices, Collins DEU' WHERE ID IN(3)
UPDATE tblImageres SET Description='iPad Pro 12"' WHERE ID IN(9)
UPDATE tblImageres SET Description='iPad Pro 11"' WHERE ID IN(7)
UPDATE tblImageres SET Description='iPad Air 3/Pro 10.5"' WHERE ID IN(5)
UPDATE tblImageres SET Description='iPad Mini//4/5/6/Air' WHERE ID IN(4)
UPDATE tblImageres SET Description='iPhone SE 2nd gen' WHERE ID IN(2)

--Inserting new TaskType 
IF NOT EXISTS (SELECT 1 FROM [dbo].[tblTaskType] WHERE ID=N'c56a4180-65aa-42ec-a945-5fd21dec0100')
INSERT [dbo].[tblTaskType] ([ID], [Name], [Description], [AzureDefinitionID]) VALUES (N'c56a4180-65aa-42ec-a945-5fd21dec0100', N'Import NewPlaceNames', N'to Import the new  PlaceNames', 100)


