CREATE TABLE tblImageResSpec(
  ConfigurationID int NULL, 
  ImageId INT, 
  ResolutionId INT, 
  ImagePath NVARCHAR(MAX)
);
GO
ALTER TABLE 
  tblImageResSpec 
ADD 
  CONSTRAINT FK_tblImageResSpec_tblImage FOREIGN KEY(ImageId) REFERENCES tblImage(ImageId);
GO
  ALTER TABLE tblImageResSpec  WITH CHECK ADD  CONSTRAINT [FK_tblImageResSpec_tblConfigurations] FOREIGN KEY([ConfigurationID])
REFERENCES [dbo].[tblConfigurations] ([ConfigurationID])
