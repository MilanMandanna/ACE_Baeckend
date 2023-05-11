CREATE TABLE tblImage(
  ImageId INT PRIMARY KEY, 
  ImageName NVARCHAR(200), 
  OriginalImagePath NVARCHAR(MAX), 
  ImageTypeId INT,
  IsSelected BIT DEFAULT 0, 
  ImageGuid NVARCHAR(500)
);

GO
ALTER TABLE 
  tblImage 
ADD 
  CONSTRAINT FK_tblImage_tblImageType FOREIGN KEY(ImageTypeId) REFERENCES tblImageType(ID);
 GO
 
