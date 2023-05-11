CREATE TABLE tblImageMap(
  ConfigurationID int NULL, 
  ImageId INT, 
  PreviousImageId INT NULL, 
  IsDeleted bit DEFAULT 0, 
  TimeStampModified timestamp NULL, 
  LastModifiedBy nvarchar(50) NULL, 
    [Action] NVARCHAR(50) NULL
);

GO
ALTER TABLE 
  tblImageMap 
ADD 
  CONSTRAINT FK_tblImageMap_tblImage FOREIGN KEY(ImageId) REFERENCES tblImage(ImageId);
ALTER TABLE tblImageMap  WITH CHECK ADD  CONSTRAINT [FK_tblImageMap_tblConfigurations] FOREIGN KEY([ConfigurationID])
REFERENCES [dbo].[tblConfigurations] ([ConfigurationID])