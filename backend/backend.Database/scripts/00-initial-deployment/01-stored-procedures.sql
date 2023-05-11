SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[SP_UploadFilesErrorLogs]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_UploadFilesErrorLogs]
END
GO

CREATE PROCEDURE [dbo].[SP_UploadFilesErrorLogs]
	@configurationId NVARCHAR(100)
AS
BEGIN
	SELECT TOP 1 errorlog FROM tbltasks WHERE ConfigurationID = @configurationId ORDER BY DateLastUpdated DESC
END

GO

IF OBJECT_ID('[dbo].[sp_image_management_DeleteImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_DeleteImage]
END
GO
CREATE PROC sp_image_management_DeleteImage
@imageId  INT,
@configurationId INT
AS 
BEGIN
	UPDATE tblImageMap SET IsDeleted=1 WHERE ImageId=@imageId AND ConfigurationID=@configurationId
END

GO
IF OBJECT_ID('[dbo].[sp_image_management_GetConfigImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetConfigImages]
END
GO

CREATE PROC sp_image_management_GetConfigImages
@configurationId  INT,
@type INT
AS 
BEGIN
SELECT img.ImageId,img.ImageName,img.IsSelected,img.OriginalImagePath FROM tblImageMap map INNER JOIN tblImage img 
		        ON img.ImageId=map.ImageId WHERE ConfigurationID=@configurationId AND img.ImageTypeId=@type and IsDeleted=0
END

GO
IF OBJECT_ID('[dbo].[sp_image_management_GetImageDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetImageDetails]
END
GO

CREATE PROC sp_image_management_GetImageDetails
@ImageId  INT
AS 
BEGIN
SELECT ImageName,OriginalImagePath FROM tblImage WHERE ImageId=@ImageId
END

GO
IF OBJECT_ID('[dbo].[sp_image_management_InsertImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_InsertImages]
END
GO
CREATE PROC sp_image_management_InsertImages
@configurationId INT,
@ImageId  INT,
@type INT,
@imageURL NVARCHAR(500),
@imageName NVARCHAR(500),
@guidFileName NVARCHAR(100)
AS 
BEGIN
INSERT INTO tblImage VALUES(@imageId,@imageName,@imageURL,@type,0,@guidFileName);
INSERT INTO tblImageMap(ConfigurationID,ImageId) VALUES(@configurationId,@imageId)
END

GO
IF OBJECT_ID('[dbo].[sp_image_management_InsertResolutionSpecImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_InsertResolutionSpecImage]
END
GO

CREATE PROC sp_image_management_InsertResolutionSpecImage
@configurationId INT,
@ImageId  INT,
@resolutionId INT,
@imageURL NVARCHAR(500)
AS 
BEGIN
INSERT INTO tblImageResSpec VALUES(@configurationId,@imageId,@resolutionId,@imageURL)
END

GO
IF OBJECT_ID('[dbo].[sp_image_management_GetResolutions]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetResolutions]
END
GO

CREATE PROC sp_image_management_GetResolutions
AS 
BEGIN
SELECT ID,resolution FROM tblImageres
END

GO
IF OBJECT_ID('[dbo].[sp_image_management_ReSetConfigImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_ReSetConfigImage]
END
GO

CREATE PROC sp_image_management_ReSetConfigImage
@configurationId INT,
@type INT
AS 
BEGIN

UPDATE T2 SET T2.IsSelected=0 FROM tblImageMap T1 INNER JOIN tblImage T2 ON T1.ImageId=T2.ImageId 
                WHERE ConfigurationID=@configurationId AND T2.ImageTypeId=@type AND T2.IsSelected=1;

END

GO
IF OBJECT_ID('[dbo].[sp_image_management_SetConfigImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_SetConfigImage]
END
GO

CREATE PROC sp_image_management_SetConfigImage
@configurationId INT,
@type INT,
@imageId INT
AS 
BEGIN

UPDATE T2 SET T2.IsSelected=1 FROM tblImageMap T1 INNER JOIN tblImage T2 ON T1.ImageId=T2.ImageId 
                 WHERE ConfigurationID=@configurationId AND T2.ImageTypeId=@type AND T2.ImageId=@imageId

END

GO
IF OBJECT_ID('[dbo].[sp_image_management_GetImageCount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetImageCount]
END
GO

CREATE PROC sp_image_management_GetImageCount
@configurationId INT
AS 
BEGIN

SELECT id,ImageType,count(B.ImageId) as imageCount FROM tblImageType A LEFT JOIN tblImage B 
                     ON A.ID=B.ImageTypeId 
                     left JOIN tblImageMap map ON B.ImageId=map.ImageId
                     WHERE map.ConfigurationID=@configurationId AND IsDeleted=0
                     GROUP BY A.ID,ImageType

END

GO
IF OBJECT_ID('[dbo].[sp_image_management_PreviewImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_PreviewImages]
END
GO

CREATE PROC sp_image_management_PreviewImages
@configurationId INT,
@imageId INT
AS 
BEGIN

SELECT ResolutionId,ImagePath,res.IsDefault,res.resolution,res.Description FROM tblImageResSpec map RIGHT JOIN tblImageres res 
                        ON map.resolutionId=res.ID WHERE ImageId=@imageId AND ConfigurationID=@configurationId

END

GO
IF OBJECT_ID('[dbo].[sp_image_management_UpdateResolutionSpecImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_UpdateResolutionSpecImage]
END
GO

CREATE PROC sp_image_management_UpdateResolutionSpecImage
@configurationId INT,
@imageId INT,
@imageURL NVARCHAR(500),
@resolutionId INT
AS 
BEGIN

UPDATE tblImageResSpec SET ImagePath=@imageURL WHERE ConfigurationID=@configurationId AND ImageId=@imageId AND ResolutionId=@resolutionId

END

GO
IF OBJECT_ID('[dbo].[sp_image_management_RenameFile]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_RenameFile]
END
GO

CREATE PROC sp_image_management_RenameFile
@imageId INT,
@type INT,
@fileName NVARCHAR(500)
AS 
BEGIN

UPDATE tblImage SET ImageName=@fileName WHERE ImageId=@imageId AND ImageTypeId=@type
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Sathya J
-- Create date: 05/16/2022
-- Description:	Get Child Configurations
-- Sample EXEC [dbo].[SP_Configuration_GetAllChlildConfigs] 1
-- =============================================
GO
IF OBJECT_ID('[dbo].[SP_Configuration_GetAllChlildConfigs]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetAllChlildConfigs]
END
GO
CREATE PROC [dbo].[SP_Configuration_GetAllChlildConfigs] @configId INT

AS

BEGIN
declare @parentDefinitionId int = (select configurationdefinitionid from tblConfigurations where configurationid = @configId);


select
--*
tblconfigurations.configurationid
from tblconfigurations
inner join tblConfigurationDefinitions
on tblconfigurations.ConfigurationDefinitionID = tblConfigurationDefinitions.ConfigurationDefinitionID
inner join (
select
max(version) as version,
configurationdefinitionid
from tblconfigurations
group by ConfigurationDefinitionID
) versions on versions.version = tblconfigurations.version and versions.ConfigurationDefinitionID = tblconfigurations.ConfigurationDefinitionID

inner join tblConfigurationTypes on tblConfigurationTypes.ConfigurationTypeID = tblConfigurationDefinitions.ConfigurationTypeID
where
tblConfigurationDefinitions.ConfigurationDefinitionParentID = @parentDefinitionId
and tblconfigurations.ConfigurationDefinitionID != @parentDefinitionId
and tblconfigurations.locked = 0;


  END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 03/29/2022
-- Description:	Get admin items and download details
-- Sample EXEC [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails] 1, 'page', 'populations'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]
@configurationId INT,
@type NVARCHAR(150),
@pageName NVARCHAR(250) = NULL
AS
BEGIN
	DECLARE @AdminItems TABLE (buttonNames NVARCHAR(500))
	DECLARE @DownloadDetails TABLE (userName NVARCHAR(500), dateUploaded DATETIME, revision INT, taskId UNIQUEIDENTIFIER)
	IF (@type = 'adminitem')
	BEGIN
		INSERT INTO @AdminItems SELECT FS.Value FROM tblFeatureSet FS
        INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
        INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        WHERE FS.Name = 'collins-admin-items' AND C.ConfigurationID = @configurationId

		SELECT * FROM @AdminItems
	END
	
	ELSE IF (@type = 'page')
	BEGIN
		INSERT INTO @DownloadDetails SELECT CommentAddedBy, DateModified, ConfigurationHistoryID, TaskID FROM tblConfigurationHistory
		WHERE ConfigurationID = @configurationId AND ContentType = @pageName AND TaskID IS NOT NULL

		SELECT * FROM @DownloadDetails
	END
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 03/25/2022
-- Description:	Import new WG Cities FROM Data Source files,
--				Date 03/31/2022 Laksmikanth Updated the SP to update ConfigurationHistoryTable
-- Sample EXEC [dbo].[SP_NewWGCities_Import] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_NewWGCities_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_NewWGCities_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_NewWGCities_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50)

AS
BEGIN
	DECLARE @geoRefId INT,@tempID INT,@tempImageID INT,@CurrentImageID INT,@tempPreviousImageID INT,@tempImagName NVARCHAR(250),@userName NVARCHAR(50);
	DECLARE @tempTextID INT,@CurrentTextID INT,@tempPreviousTextID INT,@temptextName NVARCHAR(MAX),@tempLang NVARCHAR(50);
	DECLARE @CurrentContentID INT,@tempPrevioudContentID INT;
	DECLARE @MaxImageID INT,@MaxTextID INT;

	DECLARE @tblTempWGDetailedFlightInfo_toLoop TABLE(Id INT,GeoRefID INT, Overview NVARCHAR(MAX),Features NVARCHAR(MAX),Sights NVARCHAR(MAX),Stats NVARCHAR(MAX),ImageFileName NVARCHAR(MAX),Text_Description NVARCHAR(MAX))
	DECLARE @tblTempWGCityFlightInfo_toLoop TABLE(Id INT,ImageFileName NVARCHAR(MAX),DescriptionInLang NVARCHAR(MAX),Language NVARCHAR(250),GeoRefID INT )
	DECLARE @tempWGImage TABLE(ID INT IDENTITY(1,1) ,FileName NVARCHAR(250))
	DECLARE @tempWGText TABLE(ID INT IDENTITY(1,1) ,Text_Description NVARCHAR(MAX))
	DECLARE @temptextLang TABLE(ID INT IDENTITY(1,1) ,Lang NVARCHAR(50))
	BEGIN

		--Import tblTempWGDetailedFlightInfo to a temp table to loop the entire table
		INSERT INTO @tblTempWGDetailedFlightInfo_toLoop SELECT * FROM tblTempWGDetailedFlightInfo AS TWG WHERE TWG.ImageFileName NOT IN
		(SELECT ImageFileName FROM dbo.tblWGImage WGI INNER JOIN dbo.tblWGImageMap WGIM ON WGI.ID = WGIM.ImageID WHERE WGIM.ConfigurationID =@configid) 

		--Import tblTempWGDetailedFlightInfo to a temp table to loop the entire table
		INSERT INTO @tblTempWGCityFlightInfo_toLoop SELECT * FROM tblTempWGCityFlightInfo AS TWG WHERE TWG.ImageFileName NOT IN
		(SELECT ImageFileName FROM dbo.tblWGImage WGI INNER JOIN dbo.tblWGImageMap WGIM ON WGI.ID = WGIM.ImageID WHERE WGIM.ConfigurationID =@configid) 

		--Debug
		SELECT * FROM @tblTempWGDetailedFlightInfo_toLoop
		SELECT * FROM @tblTempWGCityFlightInfo_toLoop
		--End
		
		SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
		SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)

		WHILE(SELECT COUNT(*) FROM @tblTempWGDetailedFlightInfo_toLoop) > 0
			BEGIN

				SET @geoRefId = (SELECT TOP 1 GeoRefID FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempID = (SELECT TOP 1 Id FROM @tblTempWGDetailedFlightInfo_toLoop)


				--Get Data to @tempWGImage for further processing
				INSERT INTO @tempWGImage(FileName)
				SELECT * FROM string_split((SELECT TOP 1 ImageFileName FROM @tblTempWGDetailedFlightInfo_toLoop),'|')
				DELETE @tempWGImage WHERE FileName = ''

				--Get Data to @tempWGText for further processing
				INSERT INTO @tempWGText(Text_Description)
				SELECT * FROM string_split((SELECT TOP 1 Text_Description FROM @tblTempWGDetailedFlightInfo_toLoop),'|')
				DELETE @tempWGText WHERE Text_Description = ''


				--Update tblWGImage ,tblWGText and tblWGContent which has images
				BEGIN
					DECLARE @tempID1 INT,@tempID2 INT ;
					WHILE(SELECT COUNT(*) FROM @tempWGImage) > 0
						BEGIN
							SET @tempID1 = (SELECT TOP 1  ID FROM @tempWGImage)
							SET @tempID2 = (SELECT TOP 1  ID FROM @tempWGText)
							SET @tempImagName = (SELECT TOP 1 FileName FROM @tempWGImage)
							SET @tempImageID = @tempID1 + @MaxImageID
							SET @tempPreviousImageID = (SELECT COALESCE(MAX(WGI.ID),0) FROM dbo.tblWGImage WGI 
							INNER JOIN dbo.tblWGImageMap WGIM ON WGI.ID = WGIM.ImageID WHERE WGIM.ConfigurationID = @configid AND WGI.FileName = @tempImagName)
							
							--Update tblWGImage 
							INSERT INTO tblWGImage(ImageID,FileName)
							VALUES(@tempImageID,@tempImagName)


							SET @CurrentImageID = (SELECT COALESCE(MAX(WGI.ID),0) FROM dbo.tblWGImage WGI)

							--Update tblWGImageMap 
							INSERT INTO dbo.tblWGImageMap(ConfigurationID,ImageID,PreviousImageID,IsDeleted)
							VALUES(@configid,@CurrentImageID,@tempPreviousImageID,0)

							SET @temptextName = (SELECT TOP 1 Text_Description FROM @tempWGText)
							SET @tempTextID = @tempID2 + @MaxTextID
							SET @tempPreviousTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT 
							INNER JOIN dbo.tblWGtextMap WGTM ON WGT.WGtextID = WGTM.WGtextID WHERE WGTM.ConfigurationID = @configid AND WGT.Text_EN = @temptextName)
							
							--Update tblWGText
							INSERT INTO dbo.tblWGtext(TextID,Text_EN)
							VALUES(@tempTextID,@temptextName)

							SET @CurrentTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT)
							
							--Update tblWGTextMap 
							INSERT INTO dbo.tblWGtextMap(ConfigurationID,WGtextID,PreviousWGtextID,IsDeleted)
							VALUES(@configid,@CurrentTextID,@tempPreviousTextID,0)

							--Update tblWGContent
							SET @tempPrevioudContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC 
							INNER JOIN dbo.tblWGContentMap WGCM ON WGC.WGContentID = WGCM.WGContentID WHERE WGCM.ConfigurationID = @configid AND WGC.GeoRefID = @geoRefId)
							
							INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
							VALUES(@geoRefId,1,@tempImageID,@tempTextID)							

							SET @CurrentContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC)

							--Update tblWGContenttMap 
							INSERT INTO dbo.tblWGContentMap(ConfigurationID,WGContentID,PreviousWGContentID,IsDeleted)
							VALUES(@configid,@CurrentContentID,@tempPrevioudContentID,0)

							DELETE @tempWGImage WHERE ID = @tempID1
							DELETE @tempWGText WHERE ID = @tempID2

						END					
					END
				--Update tblWGText and tblWGContent which does has images but having text
				--Updated the table With Overview Data
				SET @temptextName = (SELECT TOP 1 Overview FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = @tempID + @MaxTextID
				SET @tempPreviousTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT 
				INNER JOIN dbo.tblWGtextMap WGTM ON WGT.WGtextID = WGTM.WGtextID WHERE WGTM.ConfigurationID = @configid AND WGT.Text_EN = @temptextName)
				
				--Update tblWGText
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempImageID,@temptextName)

				SET @CurrentTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT)
				
				--Update tblWGTextMap 
				INSERT INTO dbo.tblWGtextMap(ConfigurationID,WGtextID,PreviousWGtextID,IsDeleted)
				VALUES(@configid,@CurrentTextID,@tempPreviousTextID,0)

				--Update tblWGContent
				SET @tempPrevioudContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC 
				INNER JOIN dbo.tblWGContentMap WGCM ON WGC.WGContentID = WGCM.WGContentID WHERE WGCM.ConfigurationID = @configid AND WGC.GeoRefID = @geoRefId)
				
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,1,@tempImageID,@tempTextID)							

				SET @CurrentContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC)

				--Update tblWGContentMap 
				INSERT INTO dbo.tblWGContentMap(ConfigurationID,WGContentID,PreviousWGContentID,IsDeleted)
				VALUES(@configid,@CurrentContentID,@tempPrevioudContentID,0)	

				--Updated the table With Features Data
				SET @temptextName = (SELECT TOP 1 Features FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = @tempID + @MaxTextID
				SET @tempPreviousTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT 
				INNER JOIN dbo.tblWGtextMap WGTM ON WGT.WGtextID = WGTM.WGtextID WHERE WGTM.ConfigurationID = @configid AND WGT.Text_EN = @temptextName)
				
				--Update tblWGText
				INSERT INTO dbo.tblWGtext(TextID,Text_EL)
				VALUES(@tempTextID,@temptextName)

				SET @CurrentTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT)
				
				--Update tblWGTextMap 
				INSERT INTO dbo.tblWGtextMap(ConfigurationID,WGtextID,PreviousWGtextID,IsDeleted)
				VALUES(@configid,@CurrentTextID,@tempPreviousTextID,0)

				--Update tblWGContent
				SET @tempPrevioudContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC 
				INNER JOIN dbo.tblWGContentMap WGCM ON WGC.WGContentID = WGCM.WGContentID WHERE WGCM.ConfigurationID = @configid AND WGC.GeoRefID = @geoRefId)
				
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,3,@tempImageID,@tempTextID)							

				SET @CurrentContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC)

				--Update tblWGContenttMap 
				INSERT INTO dbo.tblWGContentMap(ConfigurationID,WGContentID,PreviousWGContentID,IsDeleted)
				VALUES(@configid,@CurrentContentID,@tempPrevioudContentID,0)	

				--Updated the table With Sights Data
				SET @temptextName = (SELECT TOP 1 Sights FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = @tempID + @MaxTextID
				SET @tempPreviousTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT 
				INNER JOIN dbo.tblWGtextMap WGTM ON WGT.WGtextID = WGTM.WGtextID WHERE WGTM.ConfigurationID = @configid AND WGT.Text_EN = @temptextName)
				
				--Update tblWGText
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName)

				SET @CurrentTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT)
				
				--Update tblWGTextMap 
				INSERT INTO dbo.tblWGtextMap(ConfigurationID,WGtextID,PreviousWGtextID,IsDeleted)
				VALUES(@configid,@CurrentTextID,@tempPreviousTextID,0)

				--Update tblWGContent
				SET @tempPrevioudContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC 
				INNER JOIN dbo.tblWGContentMap WGCM ON WGC.WGContentID = WGCM.WGContentID WHERE WGCM.ConfigurationID = @configid AND WGC.GeoRefID = @geoRefId)
				
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,4,@tempImageID,@tempTextID)							

				SET @CurrentContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC)

				--Update tblWGContenttMap 
				INSERT INTO dbo.tblWGContentMap(ConfigurationID,WGContentID,PreviousWGContentID,IsDeleted)
				VALUES(@configid,@CurrentContentID,@tempPrevioudContentID,0)	

				--Updated the table With Stats Data
				SET @temptextName = (SELECT TOP 1 Stats FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = @tempID + @MaxTextID
				SET @tempPreviousTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT 
				INNER JOIN dbo.tblWGtextMap WGTM ON WGT.WGtextID = WGTM.WGtextID WHERE WGTM.ConfigurationID = @configid AND WGT.Text_EN = @temptextName)
				
				--Update tblWGText
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempImageID,@temptextName)

				SET @CurrentTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT)
				
				--Update tblWGTextMap 
				INSERT INTO dbo.tblWGtextMap(ConfigurationID,WGtextID,PreviousWGtextID,IsDeleted)
				VALUES(@configid,@CurrentTextID,@tempPreviousTextID,0)

				--Update tblWGContent
				SET @tempPrevioudContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC 
				INNER JOIN dbo.tblWGContentMap WGCM ON WGC.WGContentID = WGCM.WGContentID WHERE WGCM.ConfigurationID = @configid AND WGC.GeoRefID = @geoRefId)
				
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,5,@tempImageID,@tempTextID)							

				SET @CurrentContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC)

				--Update tblWGContentMap 
				INSERT INTO dbo.tblWGContentMap(ConfigurationID,WGContentID,PreviousWGContentID,IsDeleted)
				VALUES(@configid,@CurrentContentID,@tempPrevioudContentID,0)	
				
				DELETE @tblTempWGDetailedFlightInfo_toLoop WHERE Id = @tempID
			END
			
		WHILE(SELECT COUNT(*) FROM @tblTempWGCityFlightInfo_toLoop) > 0
			BEGIN
			
			SET @tempID = (SELECT TOP 1 Id FROM @tblTempWGCityFlightInfo_toLoop)
			SET @geoRefId = (SELECT TOP 1 GeoRefID FROM @tblTempWGCityFlightInfo_toLoop)
			
			--Get Data to @tempWGText for further processing
			INSERT INTO @tempWGText(Text_Description)
			SELECT * FROM string_split((SELECT TOP 1 DescriptionInLang FROM @tblTempWGCityFlightInfo_toLoop),'|')
			DELETE @tempWGText WHERE Text_Description = ''
	
			--Get Data to @temptextLang for further processing
			INSERT INTO @temptextLang(Lang)
			SELECT * FROM string_split((SELECT TOP 1 Language FROM @tblTempWGCityFlightInfo_toLoop),'|')
			DELETE @temptextLang WHERE Lang = ''
	
			--Get ImageID and ImageID
			SET @tempImageID = @tempID + @MaxImageID;			
			SET @tempImagName = (SELECT TOP 1 ImageFileName FROM @tblTempWGCityFlightInfo_toLoop);	
			
			--Get the PreviousImageID to insert in Maping table
			SET @tempPreviousImageID = (SELECT COALESCE(MAX(WGI.ID),0) FROM dbo.tblWGImage WGI 
					INNER JOIN dbo.tblWGImageMap WGIM ON WGI.ID = WGIM.ImageID WHERE WGIM.ConfigurationID = @configid AND WGI.FileName = @tempImagName);
				
			--Update tblWGImage		
			INSERT INTO tblWGImage(ImageID,FileName)
			VALUES(@tempImageID,@tempImagName);
			
			SET @CurrentImageID = (SELECT COALESCE(MAX(WGI.ID),0) FROM dbo.tblWGImage WGI);
	
			--Update tblWGImageMap 
			INSERT INTO dbo.tblWGImageMap(ConfigurationID,ImageID,PreviousImageID,IsDeleted)
			VALUES(@configid,@CurrentImageID,@tempPreviousImageID,0);
			
		
			
			--Insert tblWGtext TextID, Text_EN is not available at this moment
			SET @tempTextID = @tempID + @MaxTextID;		
			INSERT INTO dbo.tblWGtext(TextID) VALUES(@tempTextID);
			
			SET @CurrentTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT);				

			--Loop through tempWGText and fill dbo.tblWGtext desciption for all the languages
			DECLARE @tempID3 INT;
			WHILE(SELECT COUNT(*) FROM @tempWGText) > 0
				BEGIN				
					SET @tempID3 = (SELECT TOP 1 ID FROM @tempWGText)
					SET @tempLang = (SELECT TOP 1 Lang FROM @temptextLang)
						
	
					IF @tempLang = 'en' 
					BEGIN 
						SET @temptextName = (SELECT TOP 1 Text_Description FROM @tempWGText)	
						UPDATE dbo.tblWGtext SET Text_EN = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'de'
					BEGIN 
						UPDATE dbo.tblWGtext SET Text_DE = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'es'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_ES = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'fr'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_FR = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'it'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_IT = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'zh'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_ZH = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'zh-tw'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_HK = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'ja'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_JA = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'ko'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_KO = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'pt'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_PT = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'ru'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_RU = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'tr'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_TR = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					ELSE IF @tempLang = 'ar'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_AR = (SELECT TOP 1 Text_Description FROM @tempWGText)
					END
					DELETE @temptextLang WHERE lang = @tempLang
					DELETE @tempWGText WHERE ID = @tempID3
				END
				
			--Get the tempPreviousTextID to insert in Maping table
			SET @tempPreviousTextID = (SELECT COALESCE(MAX(WGT.WGtextID),0) FROM dbo.tblWGtext WGT 
				INNER JOIN dbo.tblWGtextMap WGTM ON WGT.WGtextID = WGTM.WGtextID WHERE WGTM.ConfigurationID = @configid AND WGT.Text_EN = @temptextName)
			
			
			INSERT INTO dbo.tblWGtextMap(ConfigurationID,WGtextID,PreviousWGtextID,IsDeleted)
			VALUES(@configid,@CurrentTextID,@tempPreviousTextID,0);			
			
			-- Get tempPrevioudContentID to update Maping Table
			SET @tempPrevioudContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC 
				INNER JOIN dbo.tblWGContentMap WGCM ON WGC.WGContentID = WGCM.WGContentID WHERE WGCM.ConfigurationID = @configid AND WGC.GeoRefID = @geoRefId)
				
			INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
			VALUES(@geoRefId,1,@tempImageID,@tempTextID)							
	
			SET @CurrentContentID = (SELECT COALESCE(MAX(WGC.WGContentID),0) FROM dbo.tblWGContent WGC)
	
			--Update tblWGContenttMap 
			INSERT INTO dbo.tblWGContentMap(ConfigurationID,WGContentID,PreviousWGContentID,IsDeleted)
			VALUES(@configid,@CurrentContentID,@tempPrevioudContentID,0)	
				
			DELETE @tblTempWGCityFlightInfo_toLoop WHERE Id = @tempID	
		END			
	DELETE tblTempWGDetailedFlightInfo
	DELETE tblTempWGCityFlightInfo

	--Update tblConfigurationHistory with the content
	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id = @LastModifiedBy)
	INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID)
	VALUES(@configid,'world guide cities',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID))
	END
END

GO

/*
1. The procedure is used to add new custom content component to tblConfigurationComponents
2. The inputs are ConfigCompPath,ConfigCompTypeID and ConfigCompName
3. execute SP_AddNewConfigurationComponent '/Customcontent/Flightdata.zip', 2, 'Flightdata.zip';
*/
IF OBJECT_ID('[dbo].[SP_AddNewConfigurationComponent]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AddNewConfigurationComponent]
END
GO

CREATE PROCEDURE [dbo].[SP_AddNewConfigurationComponent]
	 @ConfigCompPath nvarchar(500),
	 @ConfigCompTypeID int,
	 @ConfigCompName nvarchar(50)
AS
BEGIN
	BEGIN
		DECLARE @ConfigurationComponentID int
		DECLARE @retTable TABLE (id INT IDENTITY(1,1), message NVARCHAR(250))
		BEGIN TRY
			SELECT @ConfigurationComponentID = coalesce((select max(ConfigurationComponentID) + 1 from [dbo].[tblConfigurationComponents]), 1)
			BEGIN TRANSACTION
				INSERT INTO [dbo].[tblConfigurationComponents] (ConfigurationComponentID,Path,ConfigurationComponentTypeID,Name)
				VALUES
				(@ConfigurationComponentID, @ConfigCompPath, @ConfigCompTypeID ,@ConfigCompName);
			COMMIT
		END TRY
		BEGIN CATCH
			INSERT INTO @retTable(message) VALUES ('Failure')
		END CATCH
	END	
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new views if needed to custom config menu
-- Sample EXEC [dbo].[SP_AddNewConfigurationView] 'Rotating POI,Flight Info,Panorama,Flight Data,Diagnostics,Global Zoom', 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_AddNewConfigurationView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AddNewConfigurationView]
END
GO

CREATE PROCEDURE [dbo].[SP_AddNewConfigurationView]
@InputList NVARCHAR(500), 
@ConfigurationId INT 
AS
BEGIN
	DECLARE @temp TABLE(id INT IDENTITY(1,1), tempviewname NVARCHAR(500))
	DECLARE @retTable TABLE (id INT IDENTITY(1,1), message NVARCHAR(250))
	DECLARE @tempID TABLE(id INT)
	DECLARE @viewname NVARCHAR(200), @tempview NVARCHAR(200), @Id INT, @maxID INT, @tmpxml XML, @currentXML XML, @value NVARCHAR(50)

	INSERT INTO @temp SELECT * FROM STRING_SPLIT(@InputList, ',')

	WHILE (SELECT Count(*) FROM @temp) > 0
	BEGIN
		SET @Id = (SELECT TOP 1 Id FROM @temp)
		SET @tempview = (SELECT tempviewname FROM @TEMP WHERE id = @Id)
		SET @viewname = (SELECT Nodes.item.value('(./@label)[1]', 'Nvarchar(max)')
						 FROM cust.tblMenu M
						 INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID AND MM.ConfigurationID = @ConfigurationId
						 CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
						 WHERE Nodes.item.value('(./@label)[1]', 'varchar(max)') = @tempview)

		IF ( @viewname  != '')
		BEGIN
			SET @viewname = ''
			SET @viewname = (SELECT Nodes.item.value('(./@label)[1]', 'varchar(max)')
							 FROM cust.tblMenu M
							 INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID AND MM.ConfigurationID = @ConfigurationId
							 CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
							 WHERE Nodes.item.value('(./@label)[1]', 'varchar(max)') = @viewname AND
							 Nodes.item.value('(./@enable)[1]', 'varchar(200)') = 'true')
			
			IF (@viewname IS NULL OR @viewname = '')
			BEGIN
				SET @value = 'true'
				BEGIN TRY
					UPDATE M
					SET perspective.modify('replace value of (/category/item[@label =sql:variable("@tempview")]/@enable)[1] with sql:variable("@value") ')
					FROM cust.tblMenu M
					INNER JOIN cust.tblmenumap MM ON M.MenuID = MM.MenuID AND MM.ConfigurationID = @ConfigurationId
					WHERE Perspective.exist('/category/item[@label =sql:variable("@tempview")]') = 'true'
				
					INSERT INTO @retTable(message) VALUES ('Success')
				END TRY
				BEGIN CATCH
					INSERT INTO @retTable(message) VALUES ('Failure')
			END CATCH
			END
		END

		ELSE IF (@viewname IS NULL)
		BEGIN 
			INSERT INTO @tempID SELECT ISNULL(Nodes.item.value('(./@id)[1]', 'varchar(max)'), '')
			FROM cust.tblMenu M
			INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID AND MM.ConfigurationID = @ConfigurationId
			CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)

			SET @maxID = (SELECT max(id) +1 FROM @tempID)
			SET @currentXML = (SELECT M.PERSPECTIVE FROM cust.tblMenu M
			INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID AND MM.ConfigurationID = @ConfigurationId)

			SET @tmpxml = ('<item enable="true" id="'+ CONVERT(NVARCHAR(10), @maxID) +'" label="'+ @tempview +'" name="'+ REPLACE(@tempview, ' ', '') +'" quick_select="false"/>')
			SET @currentXML.modify('insert sql:variable("@tmpxml")into (category)[1]')
			BEGIN TRY
			UPDATE M
			SET M.Perspective = @currentXML
			FROM CUST.tblMenu M
			INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID AND MM.ConfigurationID = @ConfigurationId
				INSERT INTO @retTable(message) VALUES ('Success')
			END TRY
			BEGIN CATCH
				INSERT INTO @retTable(message) VALUES ('Failure')
			END CATCH
		END
		DELETE @temp WHERE Id = @Id
	END
	SELECT * FROM @retTable
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/14/2022
-- Description:	Get Airport IATA and ICAO names
-- Sample EXEC [dbo].[SP_Airport_GetNames] 1, 'iata'
-- Sample EXEC [dbo].[SP_Airport_GetNames] 1, 'icao'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_GetNames]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_GetNames]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_GetNames]
	@configurationId INT,
	@type NVARCHAR(250)
AS
BEGIN
	IF (@type = 'iata')
	BEGIN 
		SELECT 
        dbo.tblAirportInfo.ThreeLetID 
        FROM dbo.tblAirportInfo 
        INNER JOIN dbo.tblAirportInfoMap ON dbo.tblAirportInfoMap.AirportInfoID = dbo.tblAirportInfo.AirportInfoID
        WHERE dbo.tblAirportInfo.ThreeLetID IS NOT NULL AND dbo.tblAirportInfoMap.ConfigurationID = @configurationId
	END
    ELSE IF (@type = 'icao')
    BEGIN
       SELECT 
        dbo.tblAirportInfo.FourLetID 
        FROM dbo.tblAirportInfo 
        INNER JOIN dbo.tblAirportInfoMap ON dbo.tblAirportInfoMap.AirportInfoID = dbo.tblAirportInfo.AirportInfoID
        WHERE dbo.tblAirportInfo.ThreeLetID IS NOT NULL AND dbo.tblAirportInfoMap.ConfigurationID = @configurationId
    END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 02/14/2022
-- Description:	Import Latest CityPopulation Data
--				Date 02/17/2022 Lakshmikanth Updated the SP to record PreviousCityPopulationID in the tables
--				Date 03/31/2022 Laksmikanth Updated the SP to update ConfigurationHistoryTable
-- Sample EXEC [dbo].[SP_CityPopulation_Import] 1, 'userName' , '02c3cb7c-d072-4136-b19e-ded5aafa53e9'
-- =============================================

IF OBJECT_ID('[dbo].[SP_CityPopulation_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CityPopulation_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_CityPopulation_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50)	

AS
BEGIN
	DECLARE @userName NVARCHAR(50);
	DECLARE @tempCityPopIds table (CityPopId int,cityunCodeID int);
	DECLARE @tempPreviousCityPopIds table (PrevCityPopId int,PrevCityunCodeId int);

	--Copying the PreviousCityPopulationID to @tempPreviousCityPopIds
	INSERT INTO @tempPreviousCityPopIds(PrevCityPopId,PrevCityunCodeId) 
	SELECT MAX(CityPopulationID),UnCodeID FROM tblCityPopulation GROUP BY UnCodeID

	--Updating the CityPopulation from tblTempCityPopulation
	INSERT INTO [dbo].[tblCityPopulation](GeoRefID,UnCodeID,Population,SourceDate)
	--Adding newly created CityPopulationIDs in to tempCityPopIds Table for later use
	OUTPUT Inserted.CityPopulationID ,Inserted.UnCodeID into @tempCityPopIds
	SELECT  GeoRef.GeoRefId, GeoRef.UnCodeId,TempCP.Population,CONVERT(datetime, TempCP.Year) 
	FROM dbo.tblgeoref GeoRef INNER JOIN dbo.tblTempCityPopulation TempCP 
	ON TempCP.CityCode = GeoRef.UnCodeId;

	--If tblCityPopulation doesnot have any data , set null to PreviousCityPopulationID
	INSERT INTO  @tempPreviousCityPopIds (PrevCityunCodeId) SELECT cityunCodeID
	FROM @tempCityPopIds
	WHERE (SELECT COUNT(*) FROM @tempPreviousCityPopIds) = 0;

	-- Delete the existing entries in the dbo. tblCityPopulationMap table for the configuration id to avoid duplicate inserts.
	UPDATE dbo.tblCityPopulationMap
	SET IsDeleted = 1
	WHERE dbo.tblCityPopulationMap.ConfigurationID = @configid;
	
	--Delete the existing entries in the dbo.tblTempCityPopulation once update is complete !
	DELETE [dbo].[tblTempCityPopulation]

	--Update the Mapping table
	INSERT INTO [dbo].[tblCityPopulationMap](ConfigurationID,CityPopulationID,PreviousCityPopulationID,IsDeleted)
	SELECT @configid, temp1.CityPopId,temp2.PrevCityPopId,0 FROM @tempCityPopIds temp1
	INNER JOIN @tempPreviousCityPopIds temp2 ON temp2.PrevCityunCodeId = temp1.cityunCodeID;

	--Update tblConfigurationHistory with the content
	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id = @LastModifiedBy);
	INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID)
	VALUES(@configid,'populations',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID))
	
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new compass airplanes
-- Sample EXEC [dbo].[SP_Compass_AddCompassAirplanes] 18, '1,2'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_AddCompassAirplanes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_AddCompassAirplanes]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_AddCompassAirplanes]
@configurationId INT,
@idstring NVARCHAR(450)
AS
BEGIN
	DECLARE @inputstring NVARCHAR(500), @airplaneCount INT, @airplaneList NVARCHAR(500), @returnValue INT

    SET @inputstring = (SELECT (rli.value('(rli/airplanes)[1]', 'varchar(max)'))
    FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM
    ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId)

    SET @airplaneList = '' 
	SELECT @airplaneList = @airplaneList + ',' + CC.Name FROM dbo.tblConfigurationComponents CC
    INNER JOIN dbo.tblConfigurationComponentsMap CCM ON CC.[ConfigurationComponentID] = CCM.[ConfigurationComponentID] AND CCM.[ConfigurationID] = @configurationId
    WHERE CC.ConfigurationComponentTypeID IN(
    SELECT ConfigurationComponentTypeID FROM  dbo.tblConfigurationComponentType CC
	INNER JOIN dbo.tblConfigurationComponentsMap CCM ON CC.ConfigurationComponentTypeID = CCM.[ConfigurationComponentID]
	WHERE CC.Name = 'compass airplane type' AND CCM.[ConfigurationID] = @configurationId)
    AND CC.Name NOT IN(SELECT * FROM STRING_SPLIT(@inputstring, ','))
    AND CCM.[ConfigurationComponentID] IN (SELECT * FROM STRING_SPLIT(@idstring, ','))

	SET @airplaneCount = (SELECT COUNT(@inputstring))

	IF (@airplaneCount > 0)
	BEGIN
		IF (@airplaneList IS NOT NULL AND @airplaneList != '')
		BEGIN
			SELECT @airplaneList = @inputstring + @airplaneList
			UPDATE R 
            SET Rli.modify('replace value of (/rli/airplanes/text())[1] with sql:variable("@airplaneList")') 
            FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM
			ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId
            WHERE Rli.exist('/rli/airplanes') IS NOT NULL OR Rli.exist('/rli/airplanes') IS NULL 

			SET @returnValue = 1
		END
	END
	ELSE
	BEGIN
		SET @returnValue = 2
	END
	SELECT @returnValue AS returnValue
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new compass airplanes
-- Sample EXEC [dbo].[SP_Compass_GetAvailableAircraftAndLocation] 18, 'location'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetAvailableAircraftAndLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetAvailableAircraftAndLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetAvailableAircraftAndLocation]  
@configurationId INT,  
@type NVARCHAR(150)  
AS  
BEGIN  
 DECLARE @inputstring NVARCHAR(1000), @location NVARCHAR(500), @geoRefId NVARCHAR(500)
 DECLARE @tempTable TABLE (name NVARCHAR(500), georefID NVARCHAR(500))
 IF (@type = 'location')  
  BEGIN
	IF EXISTS(SELECT R.RLI
			FROM cust.tblRli R INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
			AND RM.ConfigurationID = @configurationId
			WHERE R.RLI.exist('/rli/location1') = 1)
	BEGIN
		SET @location = (SELECT rli.value('(rli/location1/@name)[1]', 'varchar(max)')
			FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM  
            ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId)

		SET @geoRefId = (SELECT rli.value('(rli/location1)[1]', 'varchar(max)')
			FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM  
            ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId)

		INSERT INTO @tempTable VALUES (@location, @geoRefId)
	END
	ELSE
	BEGIN
		INSERT INTO @tempTable VALUES ('Closest Location', -3)
	END

	IF EXISTS(SELECT R.RLI
			FROM cust.tblRli R INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
			AND RM.ConfigurationID = @configurationId
			WHERE R.RLI.exist('/rli/location2') = 1)
	BEGIN
		SET @location = (SELECT rli.value('(rli/location2/@name)[1]', 'varchar(max)')
			FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM  
            ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId)

		SET @geoRefId = (SELECT rli.value('(rli/location2)[1]', 'varchar(max)')
			FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM  
            ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId)

			INSERT INTO @tempTable VALUES (@location, @geoRefId)
	END
	ELSE
	BEGIN
		INSERT INTO @tempTable VALUES ('Closest Location', -3)
	END
	SELECT * FROM @tempTable
  END  
 ELSE IF (@type = 'aircraft')  
  BEGIN  
    SET @inputstring =(SELECT (rli.value('(rli/airplanes)[1]', 'varchar(max)')) AS Airplanes  
    FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM  
    ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId)  
    SELECT CC.Name, CC.[ConfigurationComponentID] FROM dbo.tblConfigurationComponents CC
	INNER JOIN dbo.tblConfigurationComponentsMap CCM ON CC.[ConfigurationComponentID] = CCM.[ConfigurationComponentID]
	WHERE CC.Name IN (SELECT * FROM STRING_SPLIT(@inputstring, ',')) AND CCM.[ConfigurationID] = @configurationId
  END  
 ELSE IF (@type = 'available')  
  BEGIN  

	SET @inputstring =(SELECT (rli.value('(rli/airplanes)[1]', 'varchar(max)')) AS Airplanes  
    FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM  
    ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId)  

	SELECT CC.Name, CC.[ConfigurationComponentID] FROM dbo.tblConfigurationComponents CC  
	INNER JOIN dbo.tblConfigurationComponentsMap CCM ON CC.[ConfigurationComponentID] = CCM.[ConfigurationComponentID]  
	AND CCM.[ConfigurationID] = @configurationId  
	WHERE CC.ConfigurationComponentTypeID IN(  
	SELECT ConfigurationComponentTypeID FROM  dbo.tblConfigurationComponentType CC
	INNER JOIN dbo.tblConfigurationComponentsMap CCM ON CC.ConfigurationComponentTypeID = CCM.[ConfigurationComponentID]
	WHERE CC.Name = 'compass airplane type' AND CCM.[ConfigurationID] = @configurationId)  AND CC.Name NOT IN (SELECT * FROM STRING_SPLIT(@inputstring, ','))
  END  
END  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 2/10/2022
-- Description:	Gets all the colors available in RLI xml
-- Sample EXEC [dbo].[SP_Compass_AddCompassAirplanes] 18, '1,2'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetCompassColors]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetCompassColors]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetCompassColors]
	@configurationId int
AS
BEGIN
	SELECT rli.value('(rli/loc1/@color)[1]', 'varchar(max)') as Location_1_Color,
	rli.value('(rli/loc2/@color)[1]', 'varchar(max)') as Location_2_Color,
	rli.value('(rli/compass/@color)[1]', 'varchar(max)') as CompassColorPlaceholder,
	rli.value('(rli/north_text/@color)[1]', 'varchar(max)') as NorthTextColor,
	rli.value('(rli/north_base/@color)[1]', 'varchar(max)') as NorthBaseColor,
	rli.value('(rli/poi_text/@color)[1]', 'varchar(max)') as POIColor,
	rli.value('(rli/value_text/@color)[1]', 'varchar(max)') as ValueTextColor
	FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM  
	ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 2/10/2022
-- Description:	Gets all the colors available in RLI xml
-- Sample EXEC [dbo].[SP_Compass_GetMakkahImageTextValues] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetMakkahImageTextValues]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetMakkahImageTextValues]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetMakkahImageTextValues]
	@configurationId int
AS
BEGIN
	SELECT rli.value('(rli/mecca_display/@image)[1]', 'varchar(max)') as imageValue,
	rli.value('(rli/mecca_display/@text)[1]', 'varchar(max)') as textValue
	FROM cust.tblrli R INNER JOIN cust.tblRLIMap RM  
	ON R.RLIID = RM.RLIID AND rm.ConfigurationID = @configurationId
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 01/10/2022
-- Description:	Updates colors for the compass XML
-- Sample EXEC EXEC [dbo].[SP_Views_UpdateSelectedView] 18, 'Landscape', 'true'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_UpdateCompassColors]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_UpdateCompassColors]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_UpdateCompassColors]
	@configurationId INT,
	@color NVARCHAR(500),
	@nodeName NVARCHAR(500)
AS
BEGIN
	IF (@nodeName = 'loc1')
	BEGIN
		UPDATE R 
		SET Rli.modify('replace value of (/rli/loc1/@color)[1] with sql:variable("@color")') 
		FROM cust.tblRli R 
		INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID AND RM.ConfigurationID = @configurationId
	END
	ELSE IF (@nodeName = 'loc2')
	BEGIN
		UPDATE R 
		SET Rli.modify('replace value of (/rli/loc2/@color)[1] with sql:variable("@color")') 
		FROM cust.tblRli R 
		INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID AND RM.ConfigurationID = @configurationId
	END
	ELSE IF (@nodeName = 'compass')
	BEGIN
		UPDATE R 
		SET Rli.modify('replace value of (/rli/compass/@color)[1] with sql:variable("@color")') 
		FROM cust.tblRli R 
		INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID AND RM.ConfigurationID = @configurationId
	END
	ELSE IF (@nodeName = 'north_text')
	BEGIN
		UPDATE R 
		SET Rli.modify('replace value of (/rli/north_text/@color)[1] with sql:variable("@color")') 
		FROM cust.tblRli R 
		INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID AND RM.ConfigurationID = @configurationId
	END
	ELSE IF (@nodeName = 'north_base')
	BEGIN
		UPDATE R 
		SET Rli.modify('replace value of (/rli/north_base/@color)[1] with sql:variable("@color")') 
		FROM cust.tblRli R 
		INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID AND RM.ConfigurationID = @configurationId
	END
	ELSE IF (@nodeName = 'poi_text')
	BEGIN
		UPDATE R 
		SET Rli.modify('replace value of (/rli/poi_text/@color)[1] with sql:variable("@color")') 
		FROM cust.tblRli R 
		INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID AND RM.ConfigurationID = @configurationId
	END
	ELSE IF (@nodeName = 'value_text')
	BEGIN
		UPDATE R 
		SET Rli.modify('replace value of (/rli/value_text/@color)[1] with sql:variable("@color")') 
		FROM cust.tblRli R 
		INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID AND RM.ConfigurationID = @configurationId
	END
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 02/11/2022
-- Description:	Update compass locations
-- Sample EXEC [dbo].[SP_Compass_UpdateCompassLocation] 1, '-3', 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_UpdateCompassLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_UpdateCompassLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_UpdateCompassLocation]
@configurationId INT,
@inputGeoRefId NVARCHAR(500),
@type NVARCHAR(150),
@xmlValue xml = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @cityName NVARCHAR(250), @worldClockCities XML
		DECLARE @temp TABLE(xmlData XML, cityName NVARCHAR(250))

		SET @cityName = (SELECT Description FROM dbo.tblgeoref GR
		INNER join dbo.tblGeoRefMap GRM ON 
		GR.ID = GRM.GeoRefID and GRM.ConfigurationID = @configurationId 
		WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId
		AND GR.Description NOT IN (
				SELECT WC.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.tblRli AS R
				INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
				AND RM.ConfigurationID = @configurationId
				OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V))
		AND GR.Description NOT IN(
				SELECT WC.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.tblRli AS R
				INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
				AND RM.ConfigurationID = @configurationId
				OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V)))
		
		IF (@cityName IS NOT NULL AND @cityName != '')
		BEGIN
			SET @worldClockCities =(SELECT R.Rli AS xmlData 
            FROM cust.tblRli AS R
            INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
            AND RM.ConfigurationId = @configurationId)

			INSERT INTO @temp VALUES (@worldClockCities, @cityName)
		END
		ELSE IF (@inputGeoRefId = -1)
		BEGIN
			SET @worldClockCities =(SELECT R.Rli AS xmlData 
            FROM cust.tblRli AS R
            INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
            AND RM.ConfigurationId = @configurationId)

			INSERT INTO @temp VALUES (@worldClockCities, 'Departure')
		END
		ELSE IF (@inputGeoRefId = -2)
		BEGIN
			SET @worldClockCities =(SELECT R.Rli AS xmlData 
            FROM cust.tblRli AS R
            INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
            AND RM.ConfigurationId = @configurationId)

			INSERT INTO @temp VALUES (@worldClockCities, 'Destination')
		END
		ELSE IF (@inputGeoRefId = -3)
		BEGIN
			SET @worldClockCities =(SELECT R.Rli AS xmlData 
            FROM cust.tblRli AS R
            INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
            AND RM.ConfigurationId = @configurationId)

			INSERT INTO @temp VALUES (@worldClockCities, 'Closest Location')
		END

		SELECT * FROM @temp
	END
	ELSE IF (@type = 'update')
	BEGIN
		UPDATE R
		SET Rli = @xmlValue FROM cust.tblRli AS R
            INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
            AND RM.ConfigurationId = @configurationId

		SELECT 1 AS retValue
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 02/13/2022
-- Description:	Updates Makkah values in RLI table
-- Sample EXEC [dbo].[SP_Compass_UpdateCompassValues] 1, 'image', 'true'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_UpdateCompassValues]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_UpdateCompassValues]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_UpdateCompassValues]
@configurationId INT,
@type NVARCHAR(500),
@updateValue NVARCHAR(200)
AS
BEGIN
	IF (@type = 'image')
	BEGIN
        UPDATE R 
        SET Rli.modify('replace value of (/rli/mecca_display/@image)[1] with sql:variable("@updateValue")') 
        FROM cust.tblRli R 
        INNER JOIN cust.tblRliMap Rm ON R.RLIID = RM.RLIID AND RM.ConfigurationID =  @configurationId 
        WHERE Rli.exist('/rli/mecca_display') = 'true'
	END
	ELSE IF (@type = 'text')
	BEGIN
        UPDATE R 
        SET Rli.modify('replace value of (/rli/mecca_display/@text)[1] with sql:variable("@updateValue")') 
        FROM cust.tblRli R 
        INNER JOIN cust.tblRliMap Rm ON R.RLIID = RM.RLIID AND RM.ConfigurationID =  @configurationId 
        WHERE Rli.exist('/rli/mecca_display') = 'true'
	END
END
GO
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:
-- Example: exec dbo.SP_ConfigManagement_CheckMappingTable 1, 'tblAirportInfo'
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_CheckMappingTable]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_CheckMappingTable]
END
GO

CREATE PROCEDURE dbo.SP_ConfigManagement_CheckMappingTable
	@configurationId int,
	@dataTable nvarchar(max)
AS
BEGIN
	declare @mapTable nvarchar(max) = @dataTable + 'Map'
	declare @count int = 0

	declare @sql nvarchar(max) = 'set @count = (select count(*) from ' + @mapTable + ' where configurationid = ' + cast(@configurationId as nvarchar(max)) + ')'
	exec sys.sp_executesql @sql, N'@count int out', @count = @count out

	if @count = 0
	begin
		print(@dataTable + ' -> map data not present')

	end
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Copies a record for the purpose of maintaining configuration management in the database.
--   Some assumptions are made regarding the table structure:
--   1. single primary key in the table being copied
--   2. primary key is an integer
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_CopyRecord]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_CopyRecord]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_CopyRecord]
	@tableName varchar(max),
	@primaryKeyColumn varchar(max),
	@primaryKeyValue int,
	@newPrimaryKeyValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @copyColumns varchar(max)
	declare @schema varchar(max)

	-- get the schema for the table we're copying data in
	exec dbo.SP_ConfigManagement_GetTableSchema @tableName, @schema output

	-- get the list of non-primary key columns that we need to copy
	select
		@copyColumns = coalesce(@copyColumns + ',', '') + col.[name]
	from sys.tables as tab
	inner join sys.columns col
		on col.object_id = tab.object_id
	left join sys.index_columns idx_col
		on idx_col.column_id = col.column_id and idx_col.object_id = col.object_id
	left join sys.indexes idx
		on idx.object_id = idx_col.object_id and idx.index_id = idx_col.index_id
	where 
		tab.[name] = @tableName
		and (idx.is_primary_key = 0 or idx.is_primary_key is null)

	-- generate a sql statement to 
	declare @sql nvarchar(max) = 'insert into ' + @schema + '.' + @tableName + ' (' + @copyColumns + ') select ' + @copyColumns + ' from ' + @schema + '.' + @tableName + ' where ' + @primaryKeyColumn + ' = ' + cast(@primaryKeyValue as varchar)
	set @sql = @sql + ';set @scopeIdentity = SCOPE_IDENTITY();'
	exec sys.sp_executesql @sql, N'@scopeIdentity int out', @scopeIdentity = @newPrimaryKeyValue out;

END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Looks up the key columns to used when connecting the two tables requested. The assumption here is that the two are linked by a single column.
--   If multiple are present then only the first one is returned.
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_FindMappingBetween]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_FindMappingBetween]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_FindMappingBetween]
	@mapTable varchar(max),
	@dataTable varchar(max),
	@mapColumn varchar(max) output,
	@dataColumn varchar(max) output,
	@mapSchema varchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	select top 1
		@mapColumn = col.[name],
		@dataColumn = data_col.[name],
		@mapSchema = schemas.[name]
	from sys.foreign_keys fk
		inner join sys.tables tab
			on tab.object_id = fk.parent_object_id
		inner join sys.tables data_table
			on data_table.object_id = fk.referenced_object_id and data_table.[name] = @dataTable
		inner join sys.foreign_key_columns fk_col
			on fk_col.constraint_object_id = fk.object_id
		inner join sys.columns col
			on col.column_id = fk_col.parent_column_id and col.object_id = fk_col.parent_object_id
		inner join sys.columns data_col
			on data_col.column_id = fk_col.referenced_column_id and data_col.object_id = fk_col.referenced_object_id
		inner join sys.schemas schemas
			on schemas.schema_id = tab.schema_id
	where tab.[name] = @mapTable
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 02/28/2022
-- Description:	Queries the database and retrieves the schema for a given table
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_GetTableSchema]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_GetTableSchema]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_GetTableSchema]
	@tableName varchar(max),
	@schema varchar(max) output
AS
BEGIN
	set nocount on

	select
		@schema = schemas.[name]
	from sys.schemas schemas
		inner join sys.tables tab on tab.schema_id = schemas.schema_id and tab.[name] = @tableName
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Handles populating the corresponding map table when a new record is inserted into a data table
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleAdd]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleAdd]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleAdd]
	@configurationId int,
	@dataTable nvarchar(max),
	@keyValue int
AS
BEGIN
	set nocount on

	declare @mapTable nvarchar(max) = @dataTable + 'Map'
	declare @mapColumn nvarchar(max)
	declare @dataColumn nvarchar(max)
	declare @mapSchema nvarchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	declare @sql nvarchar(max) = 'insert into ' + @mapSchema + '.' + @dataTable + 'Map (' + @mapColumn + ', Previous' + @mapColumn + ', ConfigurationID, IsDeleted, Action) values (' + cast(@keyValue as nvarchar) + ', 0, ' + cast(@configurationId as nvarchar) + ', 0, ''adding'')'
	exec sys.sp_executesql @sql
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Updates the mapping table associated with the specified data table in order
--   to mark a record as deleted
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleDelete]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleDelete]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleDelete]
	@configurationId int,
	@dataTable varchar(max),
	@keyValue int
AS
BEGIN
	set nocount on

	declare @mapTable varchar(max) = @dataTable + 'Map'
	declare @mapColumn varchar(max)
	declare @dataColumn varchar(max)
	declare @mapSchema varchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	-- flag the mapping record as deleted
	declare @sql nvarchar(max) = 'update ' + @mapSchema + '.' + @mapTable + ' set isdeleted = 1 where configurationId = ' + cast(@configurationId as nvarchar) + ' and ' + @mapColumn + ' = ' + cast(@keyValue as nvarchar)
	exec sys.sp_executesql @sql
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/17/2022
-- Description:	Used to handle record updates to records under configuration management. Updates are a bit more trickier
--   then adds or deletes. For updates, we need to create a copy of the record being updated and branch it just for the
--   configuration being updated, and then apply the updates. This procedure is responsible for detecting when a branch
--   needs to be made, copying the record, and providing the unique id of the branched record that can then be updated.
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleUpdate]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleUpdate]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleUpdate]
	@configurationId int,
	@dataTable varchar(max),
	@keyValue int,
	@useKeyValue int output			-- this is the output key that the calling stored procedure should use for applying the updates
AS
BEGIN
	set nocount on

	declare @mapTable varchar(max) = @dataTable + 'Map'
	declare @mapColumn varchar(max)
	declare @dataColumn varchar(max)
	declare @mapSchema varchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	declare @count int
	declare @sql nvarchar(max) = 'set @count = (select count(*) from ' + @mapSchema + '.' + @mapTable + ' where ' + @mapColumn + ' = ' + cast(@keyValue as nvarchar) + ')'
	exec sys.sp_executesql @sql, N'@count int out', @count = @count out

	-- record is only mapped to one configuration, which should be the current one, do nothing
	if @count <= 1
	begin
		set @useKeyValue = @keyValue
		return
	end

	-- create a copy of the record and update the mapping to point to it and connect the history
	declare @copyKey int
	exec dbo.SP_ConfigManagement_CopyRecord @dataTable, @dataColumn, @keyValue, @copyKey out

	-- update the mapping record for the configuration to point to the new record created
	set @sql = 'update ' + @mapSchema + '.' + @mapTable + ' set ' +  @mapColumn + ' = ' + cast(@copyKey as nvarchar) + ', ' + 'Previous' + @mapColumn + ' = ' + cast(@keyValue as nvarchar) + ' where configurationId = ' + cast(@configurationId as nvarchar)
	exec sys.sp_executesql @sql

	set @useKeyValue = @copyKey

END

GO
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Main Goal of this SP is to keep the Parent and Child Config values to be in Sync in all Mapping tables
--1.Get the Child config Ids for input Config ID(Parent)
--2.Loop for all child config ids
--3.Get the config table names from config_tables and loop it
--4.Each table for child config id will be updated with Parent config values
--5.Repeat the process for all child config ids

--1.For the given config id, find all the child config ids and update the config values from input config id to child config id
--2.config_tables --> new table created which holds all the config tables
--	SELECT * INTO #TEMPMapTbl FROM sys.tables tab WHERE NAME LIKE'%Map'
--	SELECT SUBSTRING(NAME,1,len(NAME)-3) AS NAME INTO config_tables FROM #TEMPMapTbl;
--	select * from config_tables
--3. This process will update all the child config id map tables wiht parent config map tables

GO
IF OBJECT_ID('[dbo].[SP_ConfigManagement_MergeConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_MergeConfig]
END
GO
CREATE PROC [dbo].[SP_ConfigManagement_MergeConfig] @configId INT
AS
  BEGIN

drop table if exists #temp_configdefid_extract
drop table if exists #temp_child_configdefid_extract
drop table if exists #tempconfigid

CREATE TABLE #tempconfigid(configurationid INT);
-- [dbo].[SP_Configuration_GetAllChlildConfigs] returns list of child config id for given config id
INSERT INTO #tempconfigid Exec [dbo].[SP_Configuration_GetAllChlildConfigs] @configId


      DECLARE @childConfigId   INT,
              @parent_keyValue NVARCHAR(10),
              @child_keyVal    NVARCHAR(10)
      DECLARE @config_table VARCHAR(100)
      DECLARE @sql NVARCHAR(MAX)
	  DECLARE @sql_1 NVARCHAR(MAX)

	  --select * from #tempconfigid

 DECLARE cur_tbl CURSOR  LOCAL STATIC FORWARD_ONLY READ_ONLY
 FOR
              SELECT tblName
              FROM   tblConfigTables

            OPEN cur_tbl

            FETCH next FROM cur_tbl INTO @config_table
			--print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN
                  --select value from parent and child config id and call the SP_ConfigManagement_HandleMerge (pass child config id)
                  DECLARE @mapTable VARCHAR(max) = @config_table + 'Map'
                  DECLARE @mapColumn VARCHAR(max)
                  DECLARE @dataColumn VARCHAR(max)
                  DECLARE @mapSchema VARCHAR(max)


                  EXEC dbo.Sp_configmanagement_findmappingbetween
                    @mapTable,
                    @config_table,
                    @mapColumn output,
                    @dataColumn output,
                    @mapSchema output

					--dECLARE @start_time DATETIME=GETDATE();
                  --Getting parent key val
                  
					DECLARE @sql_update NVARCHAR(MAX),@sql_delete NVARCHAR(MAX),@sql_insert NVARCHAR(MAX)

					--print 'running updates'
					SET  @sql_update= 'update toUpdate
							set Previous'+@mapColumn +' = toUpdate.'+@mapColumn+', 
								'+@mapColumn+' = Source.'+@mapColumn+'
							FROM '+@mapSchema + '.' + @mapTable+' (nolock) toUpdate
								inner join '+@mapSchema + '.' + @mapTable+' (nolock) Source on
									source.Previous'+@mapColumn +' = ToUpdate.'+@mapColumn+' and
									source.configurationid = '+Cast(@configId AS NVARCHAR)+' and
									toUpdate.configurationId IN( SELECT configurationid FROM #tempconfigid ) AND toUpdate.'+@mapColumn+'
									<> Source.'+@mapColumn+';';

					--PRINT @sql_update

					EXEC sys.Sp_executesql @sql_update
						-- handle deletions
						--print 'running deletions'
							SET @sql_delete= 'update toUpdate 
							set toUpdate.isDeleted = 1 
							from '+@mapSchema + '.' + @mapTable+'  (NOLOCK) toUpdate
								inner join '+@mapSchema + '.' + @mapTable+'  (NOLOCK) source on
									source.'+@mapColumn+' = toUpdate.'+@mapColumn+' and
									source.configurationId = '+Cast(@configId AS NVARCHAR)+' and
									source.isDeleted = 1 and
									toUpdate.configurationId IN( SELECT configurationid FROM #tempconfigid );';

						--print @sql_delete
						EXEC sys.Sp_executesql @sql_delete
						--		print 'running additions'
							SET @sql_insert='insert into '+@mapSchema + '.' + @mapTable+' ('+@mapColumn+', configurationid, Previous'+@mapColumn+', isdeleted) 
								select distinct '+@mapColumn+', B.configurationid, null, 0
								from '+@mapSchema + '.' + @mapTable+' (NOLOCK),#tempconfigid B 
								where '+@mapColumn+' not in (select '+@mapColumn+' from '+@mapSchema + '.' + @mapTable+' (nolock) where configurationid IN( SELECT configurationid FROM #tempconfigid)) and 
								'+@mapSchema + '.' + @mapTable+'.configurationId = '+Cast(@configId AS NVARCHAR)+' and 
								'+@mapSchema + '.' + @mapTable+'.isdeleted = 0;';
					--PRINT @sql_insert
					EXEC sys.Sp_executesql @sql_insert
                  FETCH next FROM cur_tbl INTO @config_table
              END

            CLOSE cur_tbl

            DEALLOCATE cur_tbl

  END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for branching the given configuration
-- SP executes the SP_CreateBranch procedure to branch out the given configuration.
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'Guid of the user'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_BranchConfiguration]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_BranchConfiguration]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_BranchConfiguration]
	@configurationId INT,
    @LastModifiedBy VARCHAR(MAX)
AS
BEGIN

    DECLARE @IntoConfigurationDefinitionID INT;
    SET @IntoConfigurationDefinitionID = (SELECT  dbo.tblConfigurations.ConfigurationDefinitionID FROM dbo.tblConfigurations WHERE dbo.tblConfigurations.ConfigurationID = @configurationId);

    BEGIN TRANSACTION

        -- Execute SP to Creare braching of configuration.
        EXECUTE dbo.SP_CreateBranch @configurationId,@IntoConfigurationDefinitionID,@LastModifiedBy,'Branching by Locking Configuration'

    COMMIT
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/03/2022
-- Description:	Gets the default locking comments from tblConfigurationHistory table
-- Sample EXEC [dbo].[SP_Configuration_GetDefaultLockingComments] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetDefaultLockingComments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetDefaultLockingComments]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetDefaultLockingComments]
	@configurationId INT
AS
BEGIN
   SELECT dbo.tblConfigurationHistory.UserComments
   FROM dbo.tblConfigurationHistory
   WHERE dbo.tblConfigurationHistory.ConfigurationId = @configurationId
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for Locking the child configurations of the given config id.
-- checks if the parent configuraion definition id is set to autolock, if true then locks all child config ids corresponding to the definition id.
-- SP also returns the list of configuration ids that got locked.
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'lockMessage'
-- =============================================


IF OBJECT_ID('[dbo].[SP_Configuration_LockChildConfigurations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_LockChildConfigurations]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_LockChildConfigurations]
	@configurationId INT,
    @lockMessage NVARCHAR(MAX)
AS
BEGIN

    BEGIN TRANSACTION

        -- For each child configuration, If the child is marked as AutoLock, lock the child configurations
		DROP TABLE IF EXISTS #tempconfigid
		CREATE TABLE #tempconfigid(configurationid INT);
		INSERT INTO #tempconfigid Exec [dbo].[SP_Configuration_GetAllChlildConfigs] @configurationId
        

        -- Update the configuration table for the latest configurations associated with above list of configuration Definition Id
        UPDATE tblConfig
        SET tblConfig.Locked = C.Locked, tblConfig.LockComment = C.LockComment ,tblConfig.LockDate = GETDATE()
        FROM dbo.tblConfigurations as tblConfig
        INNER JOIN 
        (
            SELECT dbo.tblConfigurations.ConfigurationDefinitionID,
            Max(dbo.tblConfigurations.Version) as Version,
            1 as  Locked,
            @lockMessage as LockComment 
            FROM dbo.tblConfigurations
            WHERE dbo.tblConfigurations.configurationid 
                IN (
                SELECT configurationid FROM #tempconfigid
                )
            GROUP BY  dbo.tblConfigurations.ConfigurationDefinitionID 
        ) as C ON tblConfig.ConfigurationDefinitionID = C.ConfigurationDefinitionID
          AND tblConfig.Version = C.Version
        
		select configurationid from #tempconfigid


    COMMIT
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for Locking the given configuration
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'lockMessage'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_LockCurrentConfiguration]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_LockCurrentConfiguration]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_LockCurrentConfiguration]
	@configurationId INT,
    @lockMessage NVARCHAR(MAX)
AS
BEGIN

    BEGIN TRANSACTION
        -- Update locked value for the current configuration
        UPDATE dbo.tblConfigurations 
        SET dbo.tblConfigurations.Locked = 1, dbo.tblConfigurations.LockComment = @lockMessage
        WHERE dbo.tblConfigurations.ConfigurationID = @configurationId;

    COMMIT
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author Abhishek Narasimha Prasad
-- Create date: 02/03/2022
-- Description:	Updates Autolock or Autodeploy columns in Configdefinition table
-- Sample EXEC [dbo].[SP_Config_UpdateAutoLockorAutoDeploy] 18, 1, 'AutoLock'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Config_UpdateAutoLockorAutoDeploy]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Config_UpdateAutoLockorAutoDeploy]
END
GO

CREATE PROCEDURE [dbo].[SP_Config_UpdateAutoLockorAutoDeploy]
	@configurationDefinitionId INT,
	@autoLock INT,
	@autoDeploy INT,
	@autoMerge INT

AS
BEGIN
	UPDATE dbo.tblConfigurationDefinitions
	SET AutoLock = @autoLock, AutoDeploy = @autoDeploy, AutoMerge = @autoMerge
	WHERE ConfigurationDefinitionID = @configurationDefinitionId
END
GO

GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
IF OBJECT_ID('[dbo].[SP_CopyConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CopyConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_CopyConfigurationDefinition]
	@sourceConfigurationDefinitionId int = 0,
	@destinationConfigurationDefinitionId int = 0,
	@description nvarchar(max) = ''
AS
BEGIN
	set nocount on;

	declare @configurationId int;
	set @configurationId = (select max(configurationid) from tblconfigurations where ConfigurationDefinitionID = @sourceConfigurationDefinitionId);

	execute sp_createbranch @configurationId, @destinationConfigurationDefinitionId, 'Script', @description

END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Updated By:		Prajna Hegde
-- Update date: 02/02/2022
-- Description:	Added tblASXiInsetMap and tblMapInsetsMap to the list of Configurable Tables. 
				-- Also added DROP PROC block so that it overwrites the existing procedure
-- =============================================

IF OBJECT_ID('[dbo].[SP_CreateBranch]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateBranch]
END
GO

CREATE PROCEDURE [dbo].[SP_CreateBranch] 
	-- Add the parameters for the stored procedure here
	@FromConfigurationID int,
	@IntoConfigurationDefinitionID int,
	@LastModifiedBy nvarchar(100),
	@Description nvarchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- report an error if we are create a new version for the same configuration definition and the version we are branching from is not locked
	declare @fromConfigurationDefinitionId int = (select configurationdefinitionid from tblconfigurations where configurationid = @FromConfigurationID)
	if @fromConfigurationDefinitionId = @IntoConfigurationDefinitionID begin
		if not exists (Select ConfigurationID from tblConfigurations where ConfigurationID = @FromConfigurationID AND Locked = 1) begin
			select -1 as ConfigurationId, 'Cannot create new configuration {Parent configuration is not locked.}' as [Message];
			return;
		end
	end

	declare @version as int = (select max(version) + 1 from tblconfigurations where configurationdefinitionid = @intoconfigurationdefinitionid);
	if @version is null begin set @version = 1 end

	-- get the next configuration id
	declare @NewConfigurationID as int = (Select max(ConfigurationID) + 1 from  [dbo].[tblConfigurations]);

	-- Create a new configuration
	insert into [dbo].[tblConfigurations]
		([ConfigurationID], [ConfigurationDefinitionID], [Version], [Locked], Description) values
		(@NewConfigurationID, @IntoConfigurationDefinitionID, @version, 0, @Description);

    declare @ParentConfigurationID as int = null
	--set @parentconfigurationid = null
	if exists (select max(configurationid) from tblconfigurations where configurationdefinitionid = @IntoConfigurationDefinitionID)
	begin
		set @ParentConfigurationID = (select max(configurationid) from tblconfigurations where configurationdefinitionid = @IntoConfigurationDefinitionID);
	end

	declare tables cursor for (select * from tblConfigTables);
	declare @tableName nvarchar(max) = ''

	open tables

	fetch next from tables into @tableName
	while @@fetch_status = 0
	begin

		print @tableName

		declare @mapTableName nvarchar(max) = @tableName + 'Map'
		declare @sql nvarchar(max) = ''
		declare @count int = 0
		declare @schema nvarchar(max) = ''
		declare @mapColumn nvarchar(max) = ''
		declare @dataColumn nvarchar(max) = ''

		exec dbo.SP_ConfigManagement_FindMappingBetween @mapTablename, @tableName, @mapColumn out, @dataColumn out, @schema out

		--set @sql = formatmessage('delete from %s.%s where configurationid > 1', @schema, @mapTableName);
		--exec sys.sp_executesql @sql
		declare @subSelect nvarchar(max) = ''
		set @subSelect = formatmessage('select %d, %s, Previous%s, IsDeleted, ''%s'' from %s.%s where isDeleted = 0 and ConfigurationId = %d', @NewConfigurationID, @mapColumn, @mapColumn, @LastModifiedBy, @schema, @mapTableName, @FromConfigurationID)
		set @sql = formatmessage('insert into %s.%s (ConfigurationID, %s, Previous%s, IsDeleted, LastModifiedBy) %s;', @schema, @mapTableName, @mapColumn, @mapColumn, @subSelect)

		print @sql
		exec sys.sp_executesql @sql

		fetch next from tables into @tableName
	end

	close tables
	deallocate tables

	Select ConfigurationId, 'New configuration has been created successfully.' as [Message] from dbo.tblConfigurations where ConfigurationId = @NewConfigurationID;
END

GO
GO

IF OBJECT_ID('[dbo].[SP_CreateConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_CreateConfigurationDefinition]
	@ParentConfigurationDefinitionID int,
	@NewConfigurationDefinitionID int,
	@ConfigurationTypeID int = 1,
	@OutputTypeID int = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	INSERT INTO tblConfigurationDefinitions (ConfigurationDefinitionID, ConfigurationDefinitionParentID, ConfigurationTypeID, OutputTypeID, Active, AutoLock, AutoDeploy)
	SELECT @NewConfigurationDefinitionID, ConfigurationDefinitionID, @ConfigurationTypeID, @OutputTypeID, 1, 1, 1 FROM tblConfigurationDefinitions WHERE tblConfigurationDefinitions.ConfigurationDefinitionID = @ParentConfigurationDefinitionID;


END

GO
GO

IF OBJECT_ID('[dbo].[SP_CreateTask]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateTask]
END
GO

CREATE   PROCEDURE [dbo].[SP_CreateTask] 	
	 @TaskTypeId  uniqueidentifier,	
	 @UserId  uniqueidentifier,
	 @TaskStatusId  int,
	 @DetailedStatus  nvarchar(500),
	 @AzureBuildId int
AS
BEGIN
	DECLARE
		@LASTID   uniqueidentifier
		DECLARE @ReturnValue int
	BEGIN
		BEGIN TRANSACTION
			SET @LASTID = NEWID();
			SET @ReturnValue = 1;

		INSERT INTO [dbo].[tblTasks] (ID, TaskTypeID,StartedByUserID,TaskStatusID
			   ,DateStarted,DateLastUpdated,PercentageComplete,DetailedStatus
			   ,AzureBuildID)
		 VALUES
			   (@LASTID, @TaskTypeId, @UserId ,@TaskStatusId, GETDATE()
			   , GETDATE(),0.2,@DetailedStatus,@AzureBuildId)	;
		 

		select tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus from tblTasks where tblTasks.ID = @LASTID;		
		COMMIT	
	END		
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/03/2022
-- Description:	Get Features details from FeatureSet table
-- Sample EXEC [dbo].[SP_Feature_GetFeatures] , 'all'
-- Sample EXEC [dbo].[SP_Feature_GetFeatures] , 'featureName'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Feature_GetFeatures]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Feature_GetFeatures]
END
GO

CREATE PROCEDURE [dbo].[SP_Feature_GetFeatures]
	@configurationId INT,
	@featureName NVARCHAR(250)
AS
BEGIN
	IF (@featureName = 'all')
	BEGIN 
		SELECT dbo.tblFeatureSet.Name, 
         dbo.tblFeatureSet.Value
        FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
         AND dbo.tblConfigurations.ConfigurationID = @configurationId 
	END
    ELSE IF (@featureName != 'all')
    BEGIN
       SELECT dbo.tblFeatureSet.Name, 
         dbo.tblFeatureSet.Value
        FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
        AND dbo.tblConfigurations.ConfigurationID = @configurationId
        WHERE dbo.tblFeatureSet.Name = @featureName
    END
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get available flightinfo parameters
-- Sample EXEC [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]
@ConfigurationId INT 
AS
BEGIN
	DECLARE @temp TABLE(infoParamDisplay NVARCHAR(500), infoParamName NVARCHAR(500))
	DECLARE @infoParamDisplay NVARCHAR(500), @infoParamName NVARCHAR(500)

	SET @infoParamName = (SELECT FS.Value FROM tblFeatureSet FS
                    INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
                    INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
                    WHERE FS.Name = 'flight-info-parameters' AND C.ConfigurationID = @configurationId)

	SET @infoParamDisplay = (SELECT FS.Value FROM tblFeatureSet FS
                    INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
                    INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
                    WHERE FS.Name = 'flight-info-parameters-display' AND C.ConfigurationID = @configurationId)

	INSERT INTO @temp(infoParamDisplay, infoParamName) VALUES (@infoParamDisplay, @infoParamName)

	SELECT * FROM @temp
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and Update flightinfo parameters names
-- Sample EXEC [dbo].[SP_FlightInfo_GetFlightInfoParameters] 1, 'get', xmldata
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_GetFlightInfoParameters]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_GetFlightInfoParameters]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_GetFlightInfoParameters]
@ConfigurationId INT,
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @temp TABLE(xmldisplayName NVARCHAR(MAX), infoParamDisplay NVARCHAR(MAX), infoParamName NVARCHAR(MAX), xmlData XML)
		DECLARE @name NVARCHAR(MAX), @infoParamDisplay NVARCHAR(MAX), @infoParamName NVARCHAR(MAX), @xml XML

		SET @name = '';
		SELECT @name = @name + ISNULL(Nodes.item.value('(./text())[1]', 'varchar(max)'), '') + ','
		FROM cust.tblWebMain M
        INNER JOIN cust.tblWebMainMap MM ON M.webmainid = MM.webmainid
        AND MM.ConfigurationID = @ConfigurationId
        CROSS APPLY M.InfoItems.nodes('//infoitem') AS Nodes(item)
        WHERE Nodes.item.value('(./@default_flight_info)[1]', 'varchar(max)') = 'true'

		SET @infoParamName = (SELECT FS.Value FROM tblFeatureSet FS
						INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
						INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
						WHERE FS.Name = 'flight-info-parameters' AND C.ConfigurationID = @ConfigurationId)

		SET @infoParamDisplay = (SELECT FS.Value FROM tblFeatureSet FS
						INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
						INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
						WHERE FS.Name = 'flight-info-parameters-display' AND C.ConfigurationID = @configurationId)

		SET @xml = (SELECT InfoItems FROM cust.tblWebMain WM INNER JOIN cust.tblWebMainMap WMM ON WM.WebMainID = WMM.WebMainID
					AND WMM.ConfigurationID = @ConfigurationId)

		INSERT INTO @temp(xmldisplayName, infoParamDisplay, infoParamName, xmlData) VALUES (@name, @infoParamDisplay, @infoParamName, @xml)

		SELECT * FROM @temp
	END
	ELSE IF(@type = 'update')
	BEGIN
		BEGIN TRY
		IF (@xmlData IS NOT NULL)
		BEGIN
			UPDATE WM
			SET InfoItems = @xmlData FROM cust.tblWebMain WM INNER JOIN cust.tblWebMainMap WMM ON WM.WebMainID = WMM.WebMainID
			AND WMM.ConfigurationID = @configurationId

			SELECT 1 AS retValue
		END
		ELSE
		BEGIN
			SELECT 0 AS retValue
		END
		END TRY
		BEGIN CATCH
		SELECT 0 AS retValue
		END CATCH
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and update the xml data for the Flightinfo
-- Sample EXEC [dbo].[SP_FlightInfo_MoveFlightInfoLocation] 18, 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_MoveFlightInfoLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_MoveFlightInfoLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_MoveFlightInfoLocation]
@configurationId INT,
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT InfoItems FROM cust.tblWebMain WM INNER JOIN cust.tblWebMainMap WMM ON WM.WebMainID = WMM.WebMainID
        AND WMM.ConfigurationID = @configurationId
	END
	ELSE IF (@type = 'update' AND @xmlData IS NOT NULL)
	BEGIN
		BEGIN TRY
			UPDATE WM
            SET InfoItems = @xmlData FROM cust.tblWebMain WM INNER JOIN cust.tblWebMainMap WMM ON WM.WebMainID = WMM.WebMainID
            AND WMM.ConfigurationID = @configurationId

			SELECT 1 AS retValue
		END TRY
		BEGIN CATCH
			SELECT 0 AS retValue
		END CATCH
	END
	ELSE
	BEGIN
		SELECT 0 AS retValue
	END
END
GO
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetMappedConfigurationRecords]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetMappedConfigurationRecords]
END
GO

CREATE PROCEDURE [dbo].[SP_GetMappedConfigurationRecords]
	@ConfigurationID int,
	@DataTable nvarchar(100),
	@primaryColumn nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @theSql nvarchar(1000)
	DECLARE @mappingTable varchar(250)

	SET @mappingTable = @DataTable + 'Map'
	SET @theSql = 'SELECT DataTable.* '
	SET @theSql = @theSql + 'FROM ' + @DataTable + ' AS DataTable '
	SET @theSql = @theSql + 'INNER JOIN ' + @DataTable + 'Map AS Mapping ON DataTable.' + @primaryColumn + ' = Mapping.' + @primaryColumn + ' '
	SET @theSql = @theSql + 'WHERE Mapping.ConfigurationID = ' + CAST(@ConfigurationID as nvarchar)
	print @theSql

	EXECUTE dbo.sp_executesql @theSql
END

GO
GO

IF OBJECT_ID('[dbo].[SP_GetPendingTasks]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPendingTasks]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPendingTasks] 	
	 @ID  uniqueidentifier,	
	 @IDType nvarchar	 
AS
BEGIN
	DECLARE
		@sql   nvarchar(max)
		DECLARE @ReturnValue int
	BEGIN
	 
	 IF UPPER(@IDType) = 'USER'
		 BEGIN
			SELECT tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus FROM dbo.tblTasks WHERE 
			StartedByUserID = @ID 
			and TaskStatusID NOT IN (Select ID from dbo.tblTaskStatus where [Name] in ('Complete'));		
		 END
	 --ELSE IF UPPER(@IDType) = 'AIRCRAFT'
		--BEGIN
		--	SELECT *  FROM dbo.tblTasks INNER JOIN [tblTaskData ] 			
		--	WHERE 
		--	StartedByUserID = @ID 
		--	and TaskStatusID NOT IN (Select ID from dbo.tblTaskStatus where [Name] in ('Complete'));
		--END
	END	
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Procedure to retrieve all Makkah page loading data
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahData] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_GetMakkahData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_GetMakkahData]
END
GO  

CREATE PROCEDURE [dbo].[SP_Makkah_GetMakkahData]  
@ConfigurationId INT   
AS  
BEGIN  
	 DECLARE @tempTable TABLE(Details NVARCHAR(500))  
	 DECLARE @tempDisplayTable Table (Id INT IDENTITY, displayName NVARCHAR(150), displayValue NVARCHAR(150))  
	 DECLARE @geoRefTable TABLE(Id INT IDENTITY, GeoRefId INT)  
	 DECLARE @geoRefId NVARCHAR(100), @location NVARCHAR(250), @xml XML  
  
  
	 --- Region to insert Makkah locations  
  
	 SET @geoRefId = (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)')  
	 FROM cust.tblrli AS R  
	 INNER JOIN cust.tblrliMap RM ON R.RLIID = RM.RLIID  
	 AND RM.ConfigurationID = @configurationId  
	 OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V))  
  
	 IF (@geoRefId IS NOT NULL)  
	 BEGIN  
	  IF(@geoRefId = '-10')  
	  BEGIN  
	   SET @location = 'Disabled'  
	  END  
	  ELSE IF(@geoRefId = '-1')  
	  BEGIN  
	   SET @location = 'Departure'  
	  END  
	  ELSE IF(@geoRefId = '-2')  
	  BEGIN  
	   SET @location = 'Destination'  
	  END  
	  ELSE IF(@geoRefId = '-3')  
	  BEGIN  
	   SET @location = 'Closest Location'  
	  END  
	  ELSE IF(@geoRefId = '-4')  
	  BEGIN  
	   SET @location = 'Current Location'  
	  END  
	  ELSE  
	  BEGIN  
	   SET @location = (SELECT GR.Description FROM dbo.tblGeoRef GR  
	   INNER JOIN dbo.tblGeoRefMap GM ON GR.Id = gm.GeoRefID  
	   AND GM.ConfigurationID = @ConfigurationId AND GR.isMakkahPoi = 1 AND GR.GeoRefId = @geoRefId)  
	  END  
  
	  INSERT INTO @tempTable VALUES(@geoRefId + ',' + @location)  
	 END  
	 ELSE  
	 BEGIN  
	  INSERT INTO @tempTable VALUES('-3, Closest Location')  
	 END  
  
	 -- Region to get prayertime values  
	 SET @geoRefId = (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId  
	 FROM cust.tblMakkah M  
	 INNER JOIN cust.tblMakkahMap MM ON M.MakkahID = MM.MakkahID  
	 AND MM.ConfigurationID = @ConfigurationId  
	 OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V))  
  
	 IF (@geoRefId IS NOT NULL)  
	 BEGIN  
	  IF(@geoRefId = '-1')  
	  BEGIN  
	   SET @location = 'Departure'  
	  END  
	  ELSE IF(@geoRefId = '-2')  
	  BEGIN  
	   SET @location = 'Destination'  
	  END  
	  ELSE IF(@geoRefId = '-3')  
	  BEGIN  
	   SET @location = 'Closest Location'  
	  END  
	  ELSE IF(@geoRefId = '-4')  
	  BEGIN  
	   SET @location = 'Current Location'  
	  END  
	  ELSE  
	  BEGIN  
	   SET @location = (SELECT GR.Description FROM dbo.tblGeoRef GR  
	   INNER JOIN dbo.tblGeoRefMap GM ON GR.Id = gm.GeoRefID AND GR.isMakkahPoi = 1  
	   AND GM.ConfigurationID = @ConfigurationId AND GR.GeoRefId = @geoRefId)  
	  END  
  
	  INSERT INTO @tempTable VALUES(@geoRefId + ',' + @location)  
	 END  
	 ELSE  
	 BEGIN  
	  INSERT INTO @tempTable VALUES('-3, Closest Location')  
	 END  
  
	 -- Region to select Makkah values  
	 SET @location = ISNULL((SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId  
	 FROM cust.tblMakkah M  
	 INNER JOIN cust.tblMakkahMap MM ON M.MakkahID = MM.MakkahID  
	 AND MM.ConfigurationID = @ConfigurationId  
	 OUTER APPLY M.Makkah.nodes('makkah/prayer_time_calculation') AS RLN(V)), '')
  
	 INSERT INTO @tempTable VALUES (@location)  
  
	 -- Region to get values for mecca display  
	 SET @xml = (SELECT Rli FROM cust.tblrli AS R  
		INNER JOIN cust.tblrliMap RM ON R.RLIID = RM.RLIID  
		AND RM.ConfigurationID = @configurationId)  
  
	 INSERT INTO @tempDisplayTable SELECT   
	 b.value('local-name(.)','varchar(50)') AS columnname,  
	 b.value('.','VARCHAR(MAX)') AS Valuename  
	 FROM @xml.nodes('/rli/mecca_display') p(k)  
	 CROSS APPLY k.nodes('@*') a(b)  
  
	 WHILE (SELECT Count(*) FROM @tempDisplayTable) > 0  
	 BEGIN  
	  SET @location = (SELECT TOP 1 displayValue FROM @tempDisplayTable)  
  
	  INSERT INTO @tempTable VALUES(@location)  
  
	  DELETE TOP (1) FROM @tempDisplayTable  
	 END  
  
	 SELECT * FROM @tempTable  
END  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get Makkah locations and available locations
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahLocations] 1, 'prayertime'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_GetMakkahLocations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_GetMakkahLocations]
END
GO

CREATE PROCEDURE [dbo].[SP_Makkah_GetMakkahLocations]
@ConfigurationId INT,
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(geoRefId INT, Descriptions NVARCHAR(500))
	DECLARE @geoRefTable Table(ID INT IDENTITY, GeoRefID INT)
	DECLARE @Id INT, @Count INT

	IF (@type = 'prayertime')
	BEGIN

		INSERT INTO @geoRefTable SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
		FROM cust.tblMakkah M
		INNER JOIN cust.tblMakkahMap MM ON M.MakkahID = MM.MakkahID
		AND MM.ConfigurationID = @ConfigurationId
		OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V)

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -4)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-4, 'Current Location')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -1)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		END
		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.tblGeoRef GR
		INNER join dbo.tblGeoRefMap GRM ON 
		GR.ID = GRM.GeoRefID AND GRM.ConfigurationID = @configurationId AND GR.isMakkahPoi = 1
		AND GR.GeoRefId NOT IN (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
				FROM cust.tblMakkah M
				INNER JOIN cust.tblMakkahMap MM ON M.MakkahID = MM.MakkahID
				AND MM.ConfigurationID = @configurationId
				OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V))
	END
	ELSE IF (@type = 'available')
	BEGIN
		
		INSERT INTO @geoRefTable SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
		FROM cust.tblrli AS R
		INNER JOIN cust.tblrliMap RM ON R.RLIID = RM.RLIID
		AND RM.ConfigurationID = @configurationId
		OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V)

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -10)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-10, 'Disabled')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -1)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -3)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, GR.Description FROM dbo.tblGeoRef GR
        INNER join dbo.tblGeoRefMap GRM ON
        GR.Id = GRM.GeoRefID AND GRM.ConfigurationID = @configurationId AND GR.isMakkahPoi = 1
		AND GR.GeoRefId NOT IN (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
				FROM cust.tblrli AS R
				INNER JOIN cust.tblrliMap RM ON R.RLIID = RM.RLIID
				AND RM.ConfigurationID = @configurationId
				OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V))
	END

	SELECT * FROM @tmpTable
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get Makkah prayer times
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahPrayerTimes] 18
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_GetMakkahPrayerTimes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_GetMakkahPrayerTimes]
END
GO

CREATE PROCEDURE [dbo].[SP_Makkah_GetMakkahPrayerTimes]
@ConfigurationId INT 
AS
BEGIN
	DECLARE @makkahParamName NVARCHAR(500), @value NVARCHAR(150)
	
	SET @value = (SELECT
    MN.V.value('(text())[1]', 'nvarchar(max)')
    FROM cust.tblMakkah AS M
    INNER JOIN cust.tblMakkahMap MM ON M.MakkahID = MM.MakkahID
    AND MM.ConfigurationID = @configurationId
    OUTER APPLY M.Makkah.nodes('makkah/prayer_time_calculation') AS MN(V))

	SET @makkahParamName = (SELECT FS.Value FROM tblFeatureSet FS
                    INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
                    INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
                    WHERE FS.Name = 'makkah-calculation-types' AND C.ConfigurationID = @configurationId)

	IF (@value != '')
		SET @makkahParamName = (Select REVERSE(STUFF(REVERSE(STUFF(REPLACE(','+@makkahParamName+',',','+@value+',',','),1,1,'')),1,1,'')))
	
	SELECT  @makkahParamName
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get Makkah locations and available locations
-- Sample EXEC [dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation] 1, 'location'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation]
@ConfigurationId INT,
@data NVARCHAR(150),
@type NVARCHAR(150)
AS
BEGIN
	IF (@type = 'available')
	BEGIN
		UPDATE M 
		SET Rli.modify('replace value of (/rli/mecca_rli/text())[1] with sql:variable("@data")') 
		FROM cust.tblRli M
		INNER JOIN cust.tblRLIMap MM ON M.RLIID = MM.RLIID
		AND MM.ConfigurationID = @ConfigurationId
	END
	ELSE IF (@type = 'prayertime')
	BEGIN
		UPDATE M 
		SET Makkah.modify('replace value of (/makkah/default_calculation_city/text())[1] with sql:variable("@data")') 
		FROM cust.tblMakkah M
		INNER JOIN cust.tblMakkahMap MM ON M.MakkahID = MM.MakkahID
		AND MM.ConfigurationID = @ConfigurationId
	END
	ELSE IF (@type = 'calculation')
	BEGIN
		UPDATE M 
		SET Makkah.modify('replace value of (/makkah/prayer_time_calculation/text())[1] with sql:variable("@data")') 
		FROM cust.tblMakkah M
		INNER JOIN cust.tblMakkahMap MM ON M.MakkahID = MM.MakkahID
		AND MM.ConfigurationID = @ConfigurationId
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/27/2022
-- Description:	Get Maps section details
-- Sample EXEC [dbo].[SP_Maps_GetConfigurations] 18, 'flyoveralerts'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Maps_GetConfigurations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Maps_GetConfigurations]
END
GO

CREATE PROCEDURE [dbo].[SP_Maps_GetConfigurations]
	@configurationId INT,
	@section NVARCHAR(250)
AS
BEGIN
	IF (@section = 'flyoveralerts')
	BEGIN
		SELECT 
        isnull(FlyOverAlert.value('(/flyover_alert/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(FlyOverAlert.value('(/flyover_alert/@alert_duration)[1]', 'INT'),'0') as AlertDuration, 
        isnull(FlyOverAlert.value('(/flyover_alert/@alert_sequential_delay)[1]', 'INT'),'0') as  AlertSequentialDelay,
        isnull(FlyOverAlert.value('(/flyover_alert/@lead_time)[1]', 'INT'),'') as ApproachAlertLeadTime
        FROM cust.tblFlyOverAlert 
        INNER JOIN cust.tblFlyOverAlertMap ON cust.tblFlyOverAlert.FlyOverAlertID = cust.tblFlyOverAlertMap.FlyOverAlertID 
        AND cust.tblFlyOverAlertMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'tabnavigation')
	BEGIN
        SELECT 
        isnull(WebMainItems.value('(/webmain/tab_nav/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(WebMainItems.value('(/webmain/tab_nav/@hover_color)[1]', 'varchar(max)'),'') as HoverColor, 
        isnull(WebMainItems.value('(/webmain/tab_nav/@next_hover_color)[1]', 'varchar(max)'),'') as NextHoverColor
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'extendedtabnavigation')
	BEGIN
        SELECT  
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/@timeout)[1]', 'INT'),'0') as TimeOut, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@highlighted_color)[1]', 'varchar(max)'),'') as HighlitedColor, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@selected_color)[1]', 'varchar(max)'),'') as SelectedColor, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@future_color)[1]', 'varchar(max)'),'') as FutureColor
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'separators')
	BEGIN
        SELECT 
        isnull(Global.value('(/global/separators/@grouping)[1]', 'varchar(max)'),'') as Grouping, 
        isnull(Global.value('(/global/separators/@decimal)[1]', 'varchar(max)'),'') as Decimal
        FROM cust.tblGlobal 
        INNER JOIN cust.tblGlobalMap ON cust.tblGlobal.CustomID = cust.tblGlobalMap.CustomID 
        AND cust.tblGlobalMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'trackline')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/trackline/@color)[1]', 'varchar(max)'),'FF00FF00') as TrackLineColor,
        isnull(MapItems.value('(/maps/trackline/@width)[1]', 'INT'),'0') as TrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline/@style)[1]', 'varchar(max)'),'eSolid') as TrackLineStyle,
        isnull(MapItems.value('(/maps/ftrackline/@color)[1]', 'varchar(max)'),'FF00FF00') as FutureTrackLineColor, 
        isnull(MapItems.value('(/maps/ftrackline/@width)[1]', 'INT'),'0') as FutureTrackLineWidth, 
        isnull(MapItems.value('(/maps/ftrackline/@style)[1]', 'varchar(max)'),'eDashed')  as FutureTrackLineStyle
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = '3dtrackline')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/trackline3d/past/@color)[1]', 'varchar(max)'),'FF00FF00') as TrackLineColor,
        isnull(MapItems.value('(/maps/trackline3d/past/@scale)[1]', 'FLOAT'),'0.0') as TrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline3d/past/@style)[1]', 'varchar(max)'),'eSolid') as TrackLineStyle,
        isnull(MapItems.value('(/maps/trackline3d/future/@color)[1]', 'varchar(max)'),'FF00FF00') as FutureTrackLineColor, 
        isnull(MapItems.value('(/maps/trackline3d/future/@scale)[1]', 'FLOAT'),'0.0') as FutureTrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline3d/future/@style)[1]', 'varchar(max)'),'eDashed') as FutureTrackLineStyle
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'borders')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/borders/@enabled)[1]', 'varchar(max)'),'false') as IsEnabled, 
        isnull(MapItems.value('(/maps/borders/@hk)[1]', 'varchar(max)'),'false') as IsHongKongEnabled, 
        isnull(MapItems.value('(/maps/broadcast_borders/@enabled)[1]', 'varchar(max)'),'false') as IsBroadcastEnabled
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'worldguide')
	BEGIN
		SELECT 
        isnull(WebMainItems.value('(/webmain/world_guide/@active)[1]', 'varchar(max)'),'') as IsEnabled
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'help')
	BEGIN
		SELECT  
        isnull(WebMainItems.value('(/webmain/help_enabled)[1]', 'varchar(max)'),'') as IsEnabled
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId 
	END
	ELSE IF (@section = 'departure' OR @section = 'destination')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/dest_marker//@color)[1]', 'varchar(max)'),'') as DestinationMarkerColor, 
        isnull(MapItems.value('(/maps/depart_marker//@color)[1]', 'varchar(max)'),'') as DepartureMarkerColor 
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/27/2022
-- Description:	Get Maps layers details
-- Sample EXEC [dbo].[SP_Maps_GetLayers] 18, 'all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Maps_GetLayers]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Maps_GetLayers]
END
GO

CREATE PROCEDURE [dbo].[SP_Maps_GetLayers]
	@configurationId INT,
	@type NVARCHAR(250)
AS
BEGIN
	IF (@type = 'layers')
	BEGIN 
		SELECT
        Nodes.LayerItem.value('(./@name)[1]','varchar(max)') as Name, 
        isnull(Nodes.LayerItem.value('(./@active)[1]','varchar(max)'),'false') as Active, 
        isnull(Nodes.LayerItem.value('(./@enable)[1]','varchar(max)'),'false') as Enabled
        FROM
        cust.tblMenu as Menu
        cross apply Menu.Layers.nodes('/category/item') as Nodes(LayerItem)
        INNER JOIN cust.tblMenuMap ON cust.tblMenuMap.MenuID = Menu.MenuID
        WHERE cust.tblMenuMap.ConfigurationID = @configurationId
	END
    ELSE IF (@type = 'all')
    BEGIN
        SELECT
        NameTable.Name as Name,
        DisplayNameTable.DisplayName as DisplayName
        FROM
        (SELECT 
        dbo.tblFeatureSet.Value as Name
        FROM 
        dbo.tblFeatureSet
        WHERE dbo.tblFeatureSet.Name = 'layers') as NameTable,
        (SELECT 
        dbo.tblFeatureSet.Value as DisplayName
        FROM 
        dbo.tblFeatureSet
        WHERE dbo.tblFeatureSet.Name = 'layers-display') as DisplayNameTable
    END
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new compass airplanes
-- Sample EXEC [dbo].[SP_Maps_UpdateSectionData] 18, 'flyoveralerts', 'active', 'false'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Maps_UpdateSectionData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Maps_UpdateSectionData]
END
GO

CREATE PROCEDURE [dbo].[SP_Maps_UpdateSectionData]
	@configurationId INT,
	@section NVARCHAR(250),
	@name NVARCHAR(250),
	@inputvalue NVARCHAR(250)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX), @count INT, @ParmDefinition NVARCHAR(500), @returnMessage NVARCHAR(500)


	IF (@section = 'flyoveralerts')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(FlyOverAlert.value(''(/flyover_alert/@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblFlyOverAlert INNER JOIN cust.tblFlyOverAlertMap ON
				cust.tblFlyOverAlert.FlyOverAlertID = cust.tblFlyOverAlertMap.FlyOverAlertID AND cust.tblFlyOverAlertMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
			SET @sql = N' UPDATE cust.tblFlyOverAlert SET  FlyOverAlert.modify(''replace value of (/flyover_alert/@'+ @name +')[1] with sql:variable("@value")'')
					WHERE cust.tblFlyOverAlert.FlyOverAlertID IN(SELECT distinct cust.tblFlyOverAlertMap.FlyOverAlertID FROM cust.tblFlyOverAlertMap WHERE 
					cust.tblFlyOverAlertMap.ConfigurationID =' 
					+ CAST(@configurationId AS NVARCHAR) + ')'
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in flyover_alert section'
		END
	END
	ELSE IF (@section = 'tabnavigation')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/tab_nav/@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
			SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/tab_nav/@'+ @name +')[1] with sql:variable("@value")'')
					WHERE cust.tblWebMain.WebMainID IN (SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE cust.tblWebMainMap.ConfigurationID = ' 
					+ CAST(@configurationId AS NVARCHAR) + ')'
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT
			
			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /webmain/tab_nav section'
		END
	END
	ELSE IF (@section = 'extendedtabnavigation')
	BEGIN
		IF CHARINDEX('color', @name) > 0
		BEGIN
			SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/extended_tab_nav/map_pois/@'+ @name +')[1]'',''VARCHAR(500)''))
				   FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				   cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				   '
				   SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

			EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

			IF (@count > 0)
			BEGIN
				SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/extended_tab_nav/map_pois/@'+ @name +')[1] with sql:variable("@value")'')
					    WHERE cust.tblWebMain.WebMainID IN(SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE
						cust.tblWebMainMap.ConfigurationID =' 
						+ CAST(@configurationId AS NVARCHAR) + ')'
						SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

				EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

				SET @returnMessage = 'Success'
			END
			ELSE
			BEGIN
				SET @returnMessage = @name + ' does not exist in /webmain/extended_tab_nav/map_pois/ section'
			END
		END
		ELSE
		BEGIN
			SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/extended_tab_nav/@'+ @name +')[1]'',''VARCHAR(500)''))
				   FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				   cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				   '
				   SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

			EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

			IF (@count > 0)
			BEGIN
				SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/extended_tab_nav/@'+ @name +')[1] with sql:variable("@value")'')
					    WHERE cust.tblWebMain.WebMainID IN(SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE
						cust.tblWebMainMap.ConfigurationID =' 
						+ CAST(@configurationId AS NVARCHAR) + ')'
						SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

				EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

				SET @returnMessage = 'Success'
			END
			ELSE
			BEGIN
				SET @returnMessage = @name + ' does not exist in /webmain/extended_tab_nav/ section'
			END
		END
	END
	ELSE IF (@section = 'separators')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(Global.value(''(/global/separators/@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblGlobal INNER JOIN cust.tblGlobalMap ON
				cust.tblGlobal.CustomID = cust.tblGlobalMap.CustomID AND cust.tblGlobalMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
			SET @sql = N' UPDATE cust.tblGlobal SET  Global.modify(''replace value of (/global/separators/@'+ @name +')[1] with sql:variable("@value")'')
					WHERE cust.tblGlobal.CustomID IN(SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE 
					cust.tblGlobalMap.ConfigurationID =' 
					+ CAST(@configurationId AS NVARCHAR) + ')'
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /global/separators/ section'
		END
	END
	ELSE IF (@section = 'help')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
			SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/'+ @name +'/text())[1] with sql:variable("@value")'')
					WHERE cust.tblWebMain.WebMainID IN(SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE 
					cust.tblWebMainMap.ConfigurationID =' 
					+ CAST(@configurationId AS NVARCHAR) + ')'
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /webmain/ section'
		END
	END
	ELSE IF (@section = 'worldguide')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/world_guide/'+'@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
			SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/world_guide/'+'@'+ @name +')[1] with sql:variable("@value")'')
					WHERE cust.tblWebMain.WebMainID IN(SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE 
					cust.tblWebMainMap.ConfigurationID =' 
					+ CAST(@configurationId AS NVARCHAR) + ')'
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /webmain/ section'
		END
	END
	ELSE IF (@section = 'trackline' OR @section = 'futuretrackline' OR @section = '3dtrackline' OR @section = 'future3dtrackline' OR @section = 'departure' OR @section = 'destination'
			OR @section = 'departure/destination' OR @section = 'borders' OR @section = 'broadcastborders')
	BEGIN
		DECLARE @prefix NVARCHAR(300)
		IF (@section = 'trackline')
		BEGIN
			SET @prefix = '/maps/trackline/'
		END
		ELSE IF (@section = 'futuretrackline')
		BEGIN
			SET @prefix = '/maps/ftrackline/'
		END
		ELSE IF (@section = '3dtrackline')
		BEGIN
			SET @prefix = '/maps/trackline3d/past/'
		END
		ELSE IF (@section = 'future3dtrackline')
		BEGIN
			SET @prefix = '/maps/trackline3d/future/'
		END
		ELSE IF (@section = 'departure')
		BEGIN
			SET @prefix = '/maps/depart_marker/'
		END
		ELSE IF (@section = 'destination')
		BEGIN
			SET @prefix = '/maps/dest_marker/'
		END
		ELSE IF (@section = 'borders')
		BEGIN
			SET @prefix = '/maps/borders/'
		END
		ELSE IF (@section = 'broadcastborders')
		BEGIN
			SET @prefix = '/maps/broadcast_borders/'
		END
		ELSE
		BEGIN
			SET @prefix = ''
		END
		SET @sql = N' SET @countret = (SELECT COUNT(MapItems.value(''('+ @prefix +'@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblMaps INNER JOIN cust.tblMapsMap ON
				cust.tblMaps.MapID = cust.tblMapsMap.MapID AND cust.tblMapsMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
			SET @sql = N' UPDATE cust.tblMaps SET  MapItems.modify(''replace value of ('+ @prefix +'@'+ @name +')[1] with sql:variable("@value")'')
					WHERE cust.tblMaps.MapID IN(SELECT distinct cust.tblMapsMap.MapID FROM cust.tblMapsMap WHERE cust.tblMapsMap.ConfigurationID =' 
					+ CAST(@configurationId AS NVARCHAR) + ')'
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /webmain/ section'
		END
	END

	SELECT @returnMessage AS message
END
GO
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_addmode] 1, 'test',1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_addmode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_addmode]
END
GO

CREATE PROC [dbo].[sp_mode_addmode]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT,
@configurationId INT

AS 
BEGIN

DECLARE @strModeNode xml = '<mode_defs><mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode></mode_defs>'

						UPDATE cust.tblModeDefs 
                        SET ModeDefs =  @strModeNode 
                         WHERE cust.tblModeDefs.ModeDefID IN ( 
                        SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                        WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId)
END
GO


GO



/****** Object:  StoredProcedure [dbo].[sp_mode_addmodeitem]    Script Date: 1/30/2022 9:14:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_addmodeitem] 1,'test',1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_addmodeitem]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_addmodeitem]
END
GO
CREATE PROC [dbo].[sp_mode_addmodeitem]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT,
@configurationId INT

AS 
BEGIN

DECLARE @strModeDef xml = '<mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode>'

	declare @modeNode xml = cast(@strModeDef as xml)

							 UPDATE cust.tblModeDefs 
                        SET ModeDefs.modify(' insert sql:variable("@modeNode") into /mode_defs[1]') 
                        WHERE cust.tblModeDefs.ModeDefID IN ( 
                        SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                        WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId)
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_getallmodes]    Script Date: 1/30/2022 9:16:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get modes for config
-- Sample EXEC [dbo].[sp_mode_getallmodes] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getallmodes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getallmodes]
END
GO

CREATE PROC [dbo].[sp_mode_getallmodes] 
@configurationId INT 
AS
BEGIN

SELECT DISTINCT 
                ModesResult.ModeName as Name,
                ModesResult.ModeId as Id,
                ScriptIdLookup.ScriptName as ScriptName,
                ScriptIdLookup.ScriptId as ScriptId

                FROM

                (SELECT 
                isnull(Nodes.Mode.value('(./@name)[1]', 'varchar(max)'),'') as ModeName,
                isnull(Nodes.Mode.value('(./@id)[1]', 'varchar(max)'),'') as ModeId,
                isnull(Nodes.Mode.value('(./mode_item/@scriptidref)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblModeDefs as Modes
                cross apply Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID
                AND cust.tblModeDefsMap.ConfigurationID = @configurationId)

                as ModesResult

                LEFT OUTER JOIN(
                   SELECT
                isnull(Nodes.Script.value('(./@name)[1]', 'varchar(max)'),'') as ScriptName,
                isnull(Nodes.Script.value('(./@id)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblScriptDefs as Scripts
                cross apply Scripts.ScriptDefs.nodes('/script_defs/script') as Nodes(Script)
                INNER JOIN cust.tblScriptDefsMap ON cust.tblScriptDefsMap.ScriptDefID = Scripts.ScriptDefID
                AND cust.tblScriptDefsMap.ConfigurationID = @configurationId
                )

                as ScriptIdLookup ON ScriptIdLookup.ScriptId = ModesResult.ScriptId

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_getmaxmodedefid]    Script Date: 1/30/2022 9:17:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get max modedef id
-- Sample EXEC [dbo].[sp_mode_getmaxmodedefid] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmaxmodedefid]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmaxmodedefid]
END
GO

CREATE PROC [dbo].[sp_mode_getmaxmodedefid]
@configurationId INT
AS
BEGIN

SELECT
                        isnull(Max(Nodes.Mode.value('(./@id)', 'int')),'0')
                        FROM cust.tblModeDefs as Modes
                        CROSS APPLY Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                        INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                        AND cust.tblModeDefsMap.ConfigurationID = @configurationId

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_getmaxmodeid]    Script Date: 1/30/2022 9:18:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get max mode id
-- Sample EXEC [dbo].[sp_mode_getmaxmodeid]
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmaxmodeid]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmaxmodeid]
END
GO

CREATE PROC [dbo].[sp_mode_getmaxmodeid]
AS
BEGIN
SELECT MAX(cust.tblModeDefs.ModeDefID) FROM cust.tblModeDefs
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_getmode]    Script Date: 1/30/2022 9:20:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get mode details for mode
-- Sample EXEC [dbo].[sp_mode_getmode] 1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmode]
END
GO

CREATE PROC [dbo].[sp_mode_getmode]
@modeid INT,
@configurationId INT
AS
BEGIN

SELECT DISTINCT 
                 ModesResult.ModeName as Name, 
                 ModesResult.ModeId as Id, 
                 ScriptIdLookup.ScriptName as ScriptName, 
                 ScriptIdLookup.ScriptId as ScriptId 

                 FROM 

                 (SELECT  
                 isnull(Nodes.Mode.value('(./@name)[1]', 'varchar(max)'),'') as ModeName, 
                 isnull(Nodes.Mode.value('(./@id)[1]', 'varchar(max)'),'') as ModeId, 
                 isnull(Nodes.Mode.value('(./mode_item/@scriptidref)[1]', 'varchar(max)'),'') as ScriptId 
                 FROM cust.tblModeDefs as Modes 
                 cross apply Modes.ModeDefs.nodes('/mode_defs/mode[@id = sql:variable("@modeid")]') as Nodes(Mode) 
                 INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                 AND cust.tblModeDefsMap.ConfigurationID = @configurationId) 

                 as ModesResult 

                 LEFT OUTER JOIN(
                    SELECT 
                 isnull(Nodes.Script.value('(./@name)[1]', 'varchar(max)'),'') as ScriptName, 
                 isnull(Nodes.Script.value('(./@id)[1]', 'varchar(max)'),'') as ScriptId 
                 FROM cust.tblScriptDefs as Scripts 
                 cross apply Scripts.ScriptDefs.nodes('/script_defs/script') as Nodes(Script)
                 INNER JOIN cust.tblScriptDefsMap ON cust.tblScriptDefsMap.ScriptDefID = Scripts.ScriptDefID 
                 AND cust.tblScriptDefsMap.ConfigurationID = @configurationId 
                 ) 

                 as ScriptIdLookup ON ScriptIdLookup.ScriptId = ModesResult.ScriptId

END
GO


GO

/****** Object:  StoredProcedure [dbo].[sp_mode_getmodeitemcount]    Script Date: 1/30/2022 9:21:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	getting mode count
-- Sample EXEC [dbo].[sp_mode_getmodeitemcount] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmodeitemcount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmodeitemcount]
END
GO

CREATE PROC [dbo].[sp_mode_getmodeitemcount]
@configurationId INT

AS
BEGIN

SELECT
                        Modes.ModeDefs.value('count(/mode_defs/mode)', 'int')
                        FROM cust.tblModeDefs as Modes
                        INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                        AND cust.tblModeDefsMap.ConfigurationID = @configurationId

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_insertmode]    Script Date: 1/30/2022 9:23:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_insertmode] 1,'test',1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_insertmode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_insertmode]
END
GO

CREATE PROC [dbo].[sp_mode_insertmode]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT
AS 
BEGIN

DECLARE @strModeNode xml = '<mode_defs><mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode></mode_defs>'

						INSERT INTO cust.tblModeDefs(ModeDefs) VALUES(@strModeNode)
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_removemode]    Script Date: 1/30/2022 9:24:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	remove node
-- Sample EXEC [dbo].[sp_mode_removemode] 1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_removemode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_removemode]
END
GO

CREATE PROC [dbo].[sp_mode_removemode]
@modeId INT,
@configurationId INT
AS
BEGIN
UPDATE cust.tblModeDefs 
                          SET ModeDefs.modify('delete /mode_defs/mode[@id = sql:variable("@modeId")]') 
                          WHERE cust.tblModeDefs.ModeDefID IN ( 
                          SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                          WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId)
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 03/07/2022
-- Description:	Import new Airports FROM navDB, Airport.csv Data Source files, If there is no new Airport now row will get modified
--				Date 03/31/2022 Laksmikanth Updated the SP to update ConfigurationHistoryTable
--				Date 04/20/2022 Laksmikanth Updated the SP to handle four letter ID with Same GeoRefID
-- Sample EXEC [dbo].[SP_NewNavDBAirports_Import] 1, 'userName' , '02c3cb7c-d072-4136-b19e-ded5aafa53e9'
-- =============================================

IF OBJECT_ID('[dbo].[SP_NewNavDBAirports_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_NewNavDBAirports_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_NewNavDBAirports_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50)
AS
BEGIN
	DECLARE @geoRefId INT,@userName NVARCHAR(50);
	DECLARE @resolutionlistTbl table (Zlevel INT, res FLOAT, resMap INT);
	DECLARE @temptbNewAirportswWithID TABLE(Id INT ,FourLetId varchar(10),ThreeLetId varchar(10),Lat varchar(50),Long varchar(50),Description varchar(250),City varchar(250),SN int ,existingGeorefId int,rank int); 
	DECLARE @tbNewAirportswWithID TABLE (Id INT,FourLetId varchar(10),ThreeLetId varchar(10),Lat varchar(50),Long varchar(50),Description varchar(250),City varchar(250),SN int ,existingGeorefId int,rank int); 

	--tbNewAirports clean up activity
	BEGIN
		--' Import source data to a temporary table. 
		SELECT T.* INTO #tbNewAirports FROM dbo.tblNavdbAirports AS T WHERE T.FourLetId NOT IN 
		(SELECT FourLetId FROM dbo.tblAirportInfo AI
			INNER JOIN dbo.tblAirportInfoMap AIM ON AI.AirportInfoID = AIM.AirportInfoID AND AIM.ConfigurationID = @configid);
	
		
		--Filter new Airport in Nav DB and Add IDs to table
		INSERT INTO @tbNewAirportswWithID(Id,FourLetId,ThreeLetId,Lat,Long,Description,City,existingGeorefId)
		SELECT (select count(*) FROM #tbNewAirports  WHERE A.SN >= SN) as ID, A.FourLetId,  A.ThreeLetId, A.Lat, A.Long, A.Description, A.City, A.existingGeorefId FROM #tbNewAirports as A ORDER by A.SN;
		
		--Extract existing GeorefIDs 
		UPDATE @tbNewAirportswWithID
			SET existingGeorefId = airinfo.GeoRefID
			FROM dbo.tblAirportInfo airinfo
			INNER JOIN @tbNewAirportswWithID on LOWER(airinfo.CityName) = LOWER(City);

		--Updating the Rank of GeoRef ID occurance in the table		
		UPDATE @tbNewAirportswWithID
			SET rank = T2.gR FROM @tbNewAirportswWithID T1
			INNER JOIN (SELECT *,RANK() OVER(PARTITION BY
                                 City, 
                                 existingGeorefId
        ORDER BY Id) gR FROM @tbNewAirportswWithID) T2 ON T1.Id = T2.Id	
		
		--resolutionlistTbl has all the resolulations and their mapings
		INSERT INTO @resolutionlistTbl values (1,0,60), (2,0,120), (3,0,240), (4,0.971922,30), (5,3,0), (6,6,0),(7,15,480),(8,30,960),
		(9,60,0),(10,75,1920),(11,150,3840),(12,300,7680),(13,600,15360),(14,1620,0),(15,2025,0)

		--Delete @temptbNewAirportswWithID
		DELETE @temptbNewAirportswWithID
		--Get GgeoRefId
		SET @geoRefId = (select max(dbo.tblGeoRef.GeoRefId) FROM  dbo.tblGeoRef);		
	END
	
	

	--Import all the Data to @temptbNewAirportswWithID
	INSERT INTO @temptbNewAirportswWithID SELECT * FROM @tbNewAirportswWithID

	WHILE(SELECT COUNT(*) FROM @temptbNewAirportswWithID) > 0
	BEGIN
		DECLARE @tempId INT, @tempGeoRefId INT, @tempCity VARCHAR(50),@tempLat FLOAT, @tempLong FLOAT, @tempCityDesc VARCHAR(250),
		@tempThreeLetID VARCHAR(10),@tempFourLetID VARCHAR(10),@GeoRefRank INT
		
		--Get all the values into a temp Variables for inserting
		--Get GeoRefId if exist If not create one
		SET @tempId = (SELECT TOP 1 id from @temptbNewAirportswWithID);
		SET @tempGeoRefId = (SELECT TOP 1 existingGeorefId FROM @temptbNewAirportswWithID WHERE id = @tempId);
		SET @tempGeoRefId = IIf((@tempGeoRefId = 0 OR @tempGeoRefId IS NULL),(@tempId+@geoRefId),@tempGeoRefId);
		SET @tempCity = (SELECT TOP 1 City FROM @temptbNewAirportswWithID WHERE id = @tempId);
		SET @tempLat = (SELECT TOP 1 Lat FROM @temptbNewAirportswWithID WHERE id = @tempId);
		SET @tempLong = (SELECT TOP 1 Long FROM @temptbNewAirportswWithID WHERE id = @tempId);
		SET @tempCityDesc = (SELECT TOP 1 Description FROM @temptbNewAirportswWithID WHERE id = @tempId);
		SET @tempThreeLetID = (SELECT TOP 1 ThreeLetId FROM @temptbNewAirportswWithID WHERE id = @tempId);
		SET @tempFourLetID = (SELECT TOP 1 FourLetId FROM @temptbNewAirportswWithID WHERE id = @tempId);
		SET @GeoRefRank = (SELECT TOP 1 rank FROM @temptbNewAirportswWithID WHERE id = @tempId);
		
		-- Update tblGeoRef Table
		IF (@GeoRefRank = 1)
		BEGIN
			DECLARE @existGeorRefTblID INT,@newGeorRefTblID INT
	
			----Get EXisting ID
			SET @existGeorRefTblID = (SELECT MAX(ID) FROM dbo.tblGeoRef GR 
			INNER JOIN dbo.tblGeoRefMap GRM ON GR.ID = GRM.GeoRefID AND GRM.ConfigurationID = @configid
			WHERE GR.GeoRefID = @tempGeoRefId);

			SET @existGeorRefTblID  = IIf(@tempGeoRefId = 0 OR @tempGeoRefId IS NULL,(NULL),@existGeorRefTblID);
	
			--tblGeoRef
			INSERT INTO dbo.tblGeoRef(GeoRefId, Description, CatTypeId, AsxiCatTypeId, PnType, 
					isAirport, isAirportPoi,isAttraction, isCapitalCountry, isCapitalState, isClosestPoi, 
					isInteractivePoi, isInteractiveSearch, isMakkahPoi, isRliPoi,isShipWreck, isSnapshot,
					isSummit, isTerrainLand, isTerrainOcean, isTimeZonePoi, isWaterBody, isWorldClockPoi, 
					isWGuide,Priority, AsxiPriority, RliAppearance, KeepNew, Display)
			VALUES (@tempGeoRefId,@tempCity,2, 10, 1, 
					0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0,0, 0);
	
			--Get New ID 
			SET @newGeorRefTblID =(SELECT MAX(ID) FROM dbo.tblGeoRef WHERE GeoRefID = @tempGeoRefId);
			
			--tblGeoRefMap
			INSERT INTO dbo.tblGeoRefMap(ConfigurationID,GeoRefId,PreviousGeoRefID,IsDeleted)
			VALUES ( @configid,@newGeorRefTblID,@existGeorRefTblID, 0)
		END
		
		-- Update tbCoverageSegment Table
		IF (@GeoRefRank = 1)		
		BEGIN
			DECLARE @existCoverageSegmentTblID INT,@newCoverageSegmentID INT;
	
			----Get EXisting ID
			SET @existCoverageSegmentTblID = (SELECT MAX(CS.ID) FROM dbo.tblCoverageSegment CS 
			INNER JOIN  dbo.tblCoverageSegmentMap CSM ON CS.ID = CSM.CoverageSegmentID AND CSM.ConfigurationID = @configid
			WHERE GeoRefID = @tempGeoRefId);

			SET @existCoverageSegmentTblID  = IIf(@tempGeoRefId = 0 OR @tempGeoRefId IS NULL,(NULL),@existCoverageSegmentTblID);
	
			--tbCoverageSegment
			INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
			VALUES(@tempGeoRefId,1,@tempLat,@tempLong,0, 0, 7);
	
			--Get New ID 
			SET @newCoverageSegmentID =(SELECT MAX(ID) FROM dbo.tblCoverageSegment WHERE GeoRefID = @tempGeoRefId);
			
			--tbCoverageSegmentMap
			INSERT INTO dbo.tblCoverageSegmentMap(ConfigurationID,CoverageSegmentID,PreviousCoverageSegmentID,IsDeleted)
			VALUES ( @configid,@newCoverageSegmentID,@existCoverageSegmentTblID, 0)
		END		

		-- Update tblAirportInfo Table
		BEGIN
			DECLARE @existAirportInfoTblID INT,@newAirportInfoID INT;
	
			----Get EXisting ID
			SET @existAirportInfoTblID = (SELECT MAX(AI.AirportInfoID) FROM dbo.tblAirportInfo AI
			INNER JOIN dbo.tblAirportInfoMap AIM ON AI.AirportInfoID = AIM.AirportInfoID AND AIM.ConfigurationID = @configid
			WHERE GeoRefID = @tempGeoRefId and @GeoRefRank = 1);

			SET @existAirportInfoTblID  = IIf(@tempGeoRefId = 0 OR @tempGeoRefId IS NULL,(NULL),@existAirportInfoTblID);
	
			--tblAirportInfo
			INSERT INTO dbo.tblAirportInfo(GeoRefID,FourLetID, ThreeLetID,Lat,Lon,CityName, dataSourceId)
			VALUES(@tempGeoRefId,@tempFourLetID,@tempThreeLetID,@tempLat,@tempLong,@tempCity,7);
	
			--Get New ID 
			SET @newAirportInfoID =(SELECT MAX(AirportInfoID) FROM dbo.tblAirportInfo WHERE GeoRefID = @tempGeoRefId);
			
			--tblAirportInfoMap
			INSERT INTO dbo.tblAirportInfoMap(ConfigurationID,AirportInfoID,PreviousAirportInfoID,IsDeleted)
			VALUES ( @configid,@newAirportInfoID,@existAirportInfoTblID, 0)
		END				
		
		-- Update tbSpelling Table only for English)
		IF (@GeoRefRank = 1)		
		BEGIN
			DECLARE @existSpellingTblID INT,@newSpellingTblID INT;				
	
			----Get EXisting ID
			SET @existSpellingTblID = (SELECT MAX(S.SpellingID) FROM dbo.tblSpelling S
			INNER JOIN  dbo.tblSpellingMap SM ON S.SpellingID = SM.SpellingID AND SM.ConfigurationID = @configid
			WHERE GeoRefID = @tempGeoRefId);

			SET @existSpellingTblID  = IIf(@tempGeoRefId = 0 OR @tempGeoRefId IS NULL,(NULL),@existSpellingTblID);
	
			--tbSpelling
			INSERT INTO dbo.tblSpelling ( GeoRefId, LanguageId, UnicodeStr, FontId, SphereMapFontId, dataSourceId )
			VALUES(@tempGeoRefId,1,@tempCity,1002,1015,7);
	
			--Get New ID 
			SET @newSpellingTblID =(SELECT MAX(SpellingID) FROM tblSpelling WHERE GeoRefID = @tempGeoRefId);
			
			--tblSpellingMap
			INSERT INTO dbo.tblSpellingMap(ConfigurationID,SpellingID,PreviousSpellingID,IsDeleted)
			VALUES ( @configid,@newSpellingTblID,@existSpellingTblID, 0)
		END
		
		-- Update tblAppearance Table only for English)
		--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions

		IF (@GeoRefRank = 1)		
		BEGIN
			DECLARE @existAppearanceTblID INT,@newAppearanceTbleID INT,@NumRes INT, @Init INT;	
			SELECT @NumRes= COUNT(*) FROM @resolutionlistTbl
			SET @Init =1
			WHILE @Init<= @NumRes
			BEGIN
				--Get EXisting ID
				SET @existAppearanceTblID = (SELECT MAX(A.AppearanceID) FROM dbo.tblAppearance A
				INNER JOIN dbo.tblAppearanceMap AM ON A.AppearanceID = AM.AppearanceID AND AM.ConfigurationID = @configid
				WHERE GeoRefID = @tempGeoRefId);

				SET @existAppearanceTblID  = IIf(@tempGeoRefId = 0 OR @tempGeoRefId IS NULL,(NULL),@existAppearanceTblID);
		
				--tblAppearance
				INSERT INTO dbo.tblAppearance(GeoRefId,Resolution, ResolutionMpp, Exclude, SphereMapExclude )
				VALUES(@tempGeoRefId,(SELECT TOP 1 res FROM @resolutionlistTbl where Zlevel =@Init),(SELECT TOP 1 resMap FROM @resolutionlistTbl where Zlevel =@Init),0,0);

				--Get New ID 
				SET @newAppearanceTbleID =(SELECT MAX(AppearanceID) FROM dbo.tblAppearance WHERE GeoRefID = @tempGeoRefId);
				
				--tblAppearanceMap
				INSERT INTO dbo.tblAppearanceMap(ConfigurationID,AppearanceID,PreviousAppearanceID,IsDeleted)
				VALUES ( @configid,@newAppearanceTbleID,@existAppearanceTblID, 0)
				SET @Init= @Init + 1
			END

		END	
		DELETE FROM @temptbNewAirportswWithID WHERE Id = @tempId;		
	END
		--Delete the temp table once import is done
		DELETE dbo.tblNavdbAirports;
		--Update tblConfigurationHistory with the content
		SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id = @LastModifiedBy)
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID)
		VALUES(@configid,'airports',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID))
END
GO	



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
IF OBJECT_ID('[dbo].[SP_PurgeConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_PurgeConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_PurgeConfigurationDefinition]
	@configurationDefinitionId int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    delete from tblconfigurations where ConfigurationDefinitionID = @configurationDefinitionId;
	delete from tblConfigurationDefinitions where ConfigurationDefinitionID = @configurationDefinitionId;
END

GO
GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_addupdatetickerparam]    Script Date: 1/30/2022 9:26:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add ticker param
-- Sample EXEC [dbo].[sp_ticker_addupdatetickerparam] 1,''
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_addupdatetickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_addupdatetickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_addupdatetickerparam]
@configurationId INT,
@xmlValue xml
AS
BEGIN
UPDATE 
                cust.tblWebMain
                SET InfoItems = @xmlValue
                 WHERE cust.tblWebMain.WebMainID IN (
	                SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap
	                WHERE cust.tblWebMainMap.ConfigurationID = @configurationId
	                )
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_getalltickerparam]    Script Date: 1/30/2022 9:28:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get all ticker params
-- Sample EXEC [dbo].[sp_ticker_getalltickerparam]
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getalltickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getalltickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_getalltickerparam]
AS
BEGIN
SELECT *
                 FROM 
                (SELECT dbo.tblFeatureSet.Value as Name
                FROM dbo.tblFeatureSet
                WHERE dbo.tblFeatureSet.Name = 'ticker-parameters') as NameTable,
                 (SELECT dbo.tblFeatureSet.Value as DisplayName
                FROM dbo.tblFeatureSet
                WHERE dbo.tblFeatureSet.Name = 'ticker-parameters-display') as DisplayNameTable
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_getinfoitems]    Script Date: 1/30/2022 9:29:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get all ticer info items
-- Sample EXEC [dbo].[sp_ticker_getinfoitems] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getinfoitems]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getinfoitems]
END
GO

CREATE PROC [dbo].[sp_ticker_getinfoitems]
@configurationId INT
AS 
BEGIN
SELECT 
                InfoItems
                FROM cust.tblWebMain
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
                AND cust.tblWebMainMap.ConfigurationID = @configurationId
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_getselectedtickerparam]    Script Date: 1/30/2022 9:30:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	retunrs selected ticker params for config
-- Sample EXEC [dbo].[sp_ticker_getselectedtickerparam] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getselectedtickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getselectedtickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_getselectedtickerparam]
@configurationId INT
AS
BEGIN
SELECT  Nodes.InfoItem.value('(.)[1]','varchar(max)') as Parameter 
                FROM 
                cust.tblWebMain as WebMain 
                cross apply WebMain.InfoItems.nodes('/infoitems/infoitem[@ticker= "true"]') as Nodes(InfoItem) 
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID 
                AND cust.tblWebMainMap.ConfigurationID = @configurationId
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_getticker]    Script Date: 1/30/2022 9:31:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	getting ticker details
-- Sample EXEC [dbo].[sp_ticker_getticker] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getticker]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getticker]
END
GO

CREATE PROC [dbo].[sp_ticker_getticker]
@configurationId INT
AS
BEGIN

SELECT 
                isnull(Ticker.value('(/ticker/@position)[1]', 'varchar(max)'),'bottom') as Position, 
                isnull(Ticker.value('(/ticker/@speed)[1]', 'INT'),'0') as Speed, 
                isnull(Ticker.value('(/ticker/@visible)[1]', 'varchar(max)'),'true') as Visible
                FROM cust.tblTicker 
                INNER JOIN cust.tblTickerMap ON cust.tblTickerMap.TickerID = cust.tblTicker.TickerID 
                AND cust.tblTickerMap.ConfigurationID = @configurationId

END
GO


GO

/****** Object:  StoredProcedure [dbo].[sp_ticker_gettickercount]    Script Date: 1/30/2022 9:33:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	returns ticker details
-- Sample EXEC [dbo].[sp_ticker_gettickercount] 'position', 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_gettickercount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_gettickercount]
END
GO

CREATE PROC [dbo].[sp_ticker_gettickercount]
@name VARCHAR(200),
@configurationId INT
AS
BEGIN

 SELECT count(b.value('local-name(.)','VARCHAR(MAX)'))
FROM cust.tblTicker b
  INNER JOIN cust.tblTickerMap c ON b.TickerID = c.TickerID 
  CROSS APPLY b.Ticker.nodes('/ticker') test(item) cross apply item.nodes('@*') a(b) WHERE ConfigurationID=@configurationId  
  AND b.value('local-name(.)','VARCHAR(MAX)')=@name

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_istickeritemdisabled]    Script Date: 1/30/2022 9:34:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	checks if the ticker disabled
-- Sample EXEC [dbo].[sp_ticker_istickeritemdisabled] 1, 'position'
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_istickeritemdisabled]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_istickeritemdisabled]
END
GO

CREATE PROC [dbo].[sp_ticker_istickeritemdisabled]
@configurationId INT,
@tickeritem VARCHAR(200)
AS
BEGIN

SELECT 
                COUNT(*) 
                FROM 
                cust.tblWebMain as WebMain 
                cross apply WebMain.InfoItems.nodes('/infoitems/infoitem') as Nodes(InfoItem)
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID 
                AND cust.tblWebMainMap.ConfigurationID = @configurationId AND Nodes.InfoItem.value('(.)[1]', 'varchar(max)') like '%'+@tickeritem+'%' 
                WHERE Nodes.InfoItem.value('(./@ticker)[1]', 'varchar(max)') like '%false%'

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_removetickerparam]    Script Date: 1/30/2022 9:36:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	remove tikcer param
-- Sample EXEC [dbo].[sp_ticker_removetickerparam] 1, 'position'
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_removetickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_removetickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_removetickerparam]
@configurationId INT,
@tickeritem VARCHAR(200)
AS
BEGIN

UPDATE cust.tblWebMain 
                 SET InfoItems.modify('delete /infoitems/infoitem[text()][contains(.,sql:variable("@tickeritem"))]') 
                 WHERE cust.tblWebMain.WebMainID IN( 
                 SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap 
                 WHERE cust.tblWebMainMap.ConfigurationID = @configurationId 
                 ) 

END
GO


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets different locations for view type
-- Sample EXEC [SP_Timezone_ColorsData] 18,'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_ColorsData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_ColorsData]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_ColorsData]  
 @configurationId INT,
 @type NVARCHAR(500),
 @color NVARCHAR(500) = NULL,
 @nodeName NVARCHAR(500) = NULL
AS  
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT PlaceNames.value('(world_timezone_placenames/@depart_color)[1]', 'varchar(max)') as Departure_Color,
		PlaceNames.value('(world_timezone_placenames/@dest_color)[1]', 'varchar(max)') as Destination_Color,
		PlaceNames.value('(world_timezone_placenames/@timeatpp_color)[1]', 'varchar(max)') as Present_Color 
		FROM cust.tblWorldTimeZonePlaceNames TZ INNER JOIN cust.tblWorldTimeZonePlaceNamesMap TZM    
		ON TZ.PlaceNameID = TZM.PlaceNameID AND TZM.ConfigurationId = @configurationId
	END
	ELSE IF (@type = 'update')
	BEGIN
		IF (@nodeName = 'depart_color')  
		BEGIN  
			UPDATE TZ   
			SET PlaceNames.modify('replace value of (/world_timezone_placenames/@depart_color)[1] with sql:variable("@color")')   
			FROM cust.tblWorldTimeZonePlaceNames TZ INNER JOIN cust.tblWorldTimeZonePlaceNamesMap TZM    
			ON TZ.PlaceNameID = TZM.PlaceNameID AND TZM.ConfigurationId = @configurationId
		END  
		ELSE IF (@nodeName = 'dest_color')  
		BEGIN  
			UPDATE TZ   
			SET PlaceNames.modify('replace value of (/world_timezone_placenames/@dest_color)[1] with sql:variable("@color")')   
			FROM cust.tblWorldTimeZonePlaceNames TZ INNER JOIN cust.tblWorldTimeZonePlaceNamesMap TZM    
			ON TZ.PlaceNameID = TZM.PlaceNameID AND TZM.ConfigurationId = @configurationId
		END  
		ELSE IF (@nodeName = 'timeatpp_color')  
		BEGIN  
			UPDATE TZ   
			SET PlaceNames.modify('replace value of (/world_timezone_placenames/@timeatpp_color)[1] with sql:variable("@color")')   
			FROM cust.tblWorldTimeZonePlaceNames TZ INNER JOIN cust.tblWorldTimeZonePlaceNamesMap TZM    
			ON TZ.PlaceNameID = TZM.PlaceNameID AND TZM.ConfigurationId = @configurationId
		END
	END
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get timezone locations
-- Sample EXEC [dbo].[SP_Timezone_GetAvailableTimeoneLocation] 18
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_GetAvailableTimeoneLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_GetAvailableTimeoneLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_GetAvailableTimeoneLocation]
@configurationId INT
AS
BEGIN
	SELECT
    TZV.V.value('@name', 'nvarchar(max)') AS city,
    TZV.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
    FROM cust.tblWorldTimeZonePlaceNames AS TZ
    INNER JOIN cust.tblWorldTimeZonePlaceNamesMap TZM ON TZ.PlaceNameID = TZM.PlaceNameID
    AND TZM.ConfigurationID = @configurationId
    OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZV(V)
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add or remove timezone locations
-- Sample EXEC [dbo].[SP_Timezone_UpdateTimezoneLocation] 18, '25,9', 'remove'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_UpdateTimezoneLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_UpdateTimezoneLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_UpdateTimezoneLocation]
@configurationId INT,
@InputList NVARCHAR(500),
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(Descriptions NVARCHAR(500), id INT)
	DECLARE @xmlData XML, @tmpxml XML, @currentXML XML, @data NVARCHAR(250), @geoRefID NVARCHAR(150)
	DECLARE @retTable TABLE (id INT)

	SET @xmlData = (SELECT PlaceNames as xmlData FROM cust.tblWorldTimeZonePlaceNames TZ
	INNER JOIN CUST.tblWorldTimeZonePlaceNamesMap TZM
	ON TZ.PlaceNameID = TZM.PlaceNameID AND TZM.ConfigurationID = @configurationId)

	IF (@type = 'add')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.tblgeoref GR
		INNER join dbo.tblGeoRefMap GRM ON 
		GR.Id = GRM.GeoRefID and GRM.ConfigurationID = @configurationId 
		WHERE GR.isTimeZonePoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description NOT IN (
		SELECT ISNULL(TZN.V.value('@name', 'nvarchar(max)'), '') AS city
		FROM cust.tblWorldTimeZonePlaceNames TZ
		INNER JOIN cust.tblWorldTimeZonePlaceNamesMap TZM
		ON tz.PlaceNameID = tzm.PlaceNameID AND TZM.ConfigurationID = @configurationId
		OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZN(V))
	END
	ELSE IF (@type = 'remove')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.tblgeoref GR
		INNER join dbo.tblGeoRefMap GRM ON 
		GR.Id = GRM.GeoRefID and GRM.ConfigurationID = @configurationId 
		WHERE GR.isTimeZonePoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description IN (
		SELECT ISNULL(TZN.V.value('@name', 'nvarchar(max)'), '') AS city
		FROM cust.tblWorldTimeZonePlaceNames TZ
		INNER JOIN cust.tblWorldTimeZonePlaceNamesMap TZM
		ON tz.PlaceNameID = tzm.PlaceNameID AND TZM.ConfigurationID = @configurationId
		OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZN(V))
	END

	SET @currentXML = (SELECT TZ.PlaceNames FROM cust.tblWorldTimeZonePlaceNames TZ
			INNER JOIN CUST.tblWorldTimeZonePlaceNamesMap TZM
			ON TZ.PlaceNameID = TZM.PlaceNameID AND TZM.ConfigurationID = @ConfigurationId)

	WHILE (SELECT Count(*) FROM @tmpTable) > 0
	BEGIN
		SET @data = (SELECT TOP 1 Descriptions FROM @tmpTable)
		SET @geoRefID = (SELECT TOP 1 id FROM @tmpTable)
		
		IF (@type = 'add')
		BEGIN
			SET @tmpxml = ('<city name="'+ @data +'">'+ @geoRefID +'</city>')
			SET @currentXML.modify('insert sql:variable("@tmpxml")into (world_timezone_placenames)[1]')
		END
		ELSE IF (@type = 'remove')
		BEGIN
			SET @currentXML.modify('delete /world_timezone_placenames/city[text() = sql:variable("@geoRefID")]')
		END

		BEGIN TRY
		UPDATE TZ
			SET TZ.PlaceNames = @currentXML
			FROM cust.tblWorldTimeZonePlaceNames TZ
			INNER JOIN CUST.tblWorldTimeZonePlaceNamesMap TZM
			ON TZ.PlaceNameID = TZM.PlaceNameID AND TZM.ConfigurationID = @ConfigurationId
			INSERT INTO @retTable(id) VALUES (1)
		END TRY
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
		DELETE @tmpTable WHERE Id = @geoRefID
	END
	SELECT * FROM @retTable
END
GO
GO

IF OBJECT_ID('[dbo].[SP_UpdateTask]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_UpdateTask]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateTask] 	
	 @TaskId  uniqueidentifier,		
	 @TaskStatusId  int,
	 @PercentageComplete float,
	 @DetailedStatus  nvarchar	 
AS
BEGIN
	DECLARE
		@LASTID   uniqueidentifier
		DECLARE @ReturnValue int
	BEGIN		
		SET @ReturnValue = 1;
		 Update [dbo].[tblTasks] SET TaskStatusID = @TaskStatusId
           ,DateLastUpdated = GETDATE(),PercentageComplete = @PercentageComplete,DetailedStatus = @DetailedStatus
				WHERE ID = @TaskId	  
		 select tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus from tblTasks where tblTasks.ID = @TaskId;
		  return @ReturnValue
	END	
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Updates enable status to false for that view
-- Sample EXEC [dbo].[SP_Views_UpdateSelectedView] 18, 'Landscape', 'false'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_DisableSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_DisableSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_DisableSelectedView]
@configurationId INT,
@viewName NVARCHAR(500),
@updateValue NVARCHAR(200)
AS
BEGIN
	UPDATE M
	SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@enable)[1] with sql:variable("@updateValue")')
	FROM cust.tblMenu M
	INNER JOIN cust.tblmenumap MM on m.menuid = MM.menuid and mm.ConfigurationID =  @configurationId
	WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true'

	UPDATE M
	SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")')
	FROM cust.tblMenu M
	INNER JOIN cust.tblmenumap MM on m.menuid = MM.menuid and mm.ConfigurationID =  @configurationId
	WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true'
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets all views for configuration ID
-- Sample EXEC [dbo].[SP_Views_GetAllViewDetails] 18, 'all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_GetAllViewDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_GetAllViewDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_GetAllViewDetails]
@configurationId INT,
@type NVARCHAR(500)
AS
BEGIN
	IF (@type = 'all')
	BEGIN
		SELECT ISNULL(Nodes.item.value('(./@label)[1]', 'varchar(max)'), '') AS name,
		ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), '') AS preset
		FROM cust.tblMenu M
		INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID
		AND MM.ConfigurationID = @configurationId
		CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
		WHERE Nodes.item.value('(./@enable)[1]', 'varchar(max)') = 'true'
	END
	ELSE IF (@type = 'disabled')
	BEGIN
		SELECT ISNULL(Nodes.item.value('(./@label)[1]', 'varchar(max)'), '') AS name,
		ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), '') AS preset
		FROM cust.tblMenu M
		INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID
		AND MM.ConfigurationID = @configurationId
		CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
		WHERE Nodes.item.value('(./@enable)[1]', 'varchar(max)') = 'false'
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets different locations for view type
-- Sample EXEC [dbo].[SP_Views_GetLocationForSelectedView] 18,'timezone'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_GetLocationForSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_GetLocationForSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_GetLocationForSelectedView]
@configurationId INT,
@viewName NVARCHAR(500)
AS
BEGIN
	DECLARE @cityXML XML, @DestinationXML XML, @DepartureXML XML, @ClosestXML XML, @Location1XML XML, @Location2XML XML
	DECLARE @tmpTable Table(geoRefId INT, Descriptions NVARCHAR(500))
	
	IF (@viewName = 'compass')
	BEGIN

		SET @Location1XML = (SELECT R.Rli
						FROM cust.tblRli AS R
						INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
						AND RM.ConfigurationID = @configurationId
						WHERE R.Rli.exist('/rli/location1[@name = "Closest Location"]') = 1)
		SET @Location2XML = (SELECT R.Rli
						FROM cust.tblRli AS R
						INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
						AND RM.ConfigurationID = @configurationId
						WHERE R.Rli.exist('/rli/location2[@name = "Closest Location"]') = 1)

		IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		END

		SET @Location1XML = (SELECT R.Rli
						FROM cust.tblRli AS R
						INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
						AND RM.ConfigurationID = @configurationId
						WHERE R.Rli.exist('/rli/location1[@name = "Departure"]') = 1)
		SET @Location2XML = (SELECT R.Rli
						FROM cust.tblRli AS R
						INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
						AND RM.ConfigurationID = @configurationId
						WHERE R.Rli.exist('/rli/location2[@name = "Departure"]') = 1)

		IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		END

		SET @Location1XML = (SELECT R.Rli
						FROM cust.tblRli AS R
						INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
						AND RM.ConfigurationID = @configurationId
						WHERE R.Rli.exist('/rli/location1[@name = "Destination"]') = 1)
		SET @Location2XML = (SELECT R.Rli
						FROM cust.tblRli AS R
						INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
						AND RM.ConfigurationID = @configurationId
						WHERE R.Rli.exist('/rli/location2[@name = "Destination"]') = 1)

		IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.tblGeoRef GR
		INNER join dbo.tblGeoRefMap GRM ON 
		GR.ID = GRM.GeoRefID and GRM.ConfigurationID = @configurationId
		WHERE GR.isRliPoi = 1 AND GR.GeoRefID NOT IN (
				SELECT ISNULL(WC.V.value('text()[1]', 'nvarchar(max)'), '') AS city
				FROM cust.tblRli AS R
				INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
				AND RM.ConfigurationID = @configurationId
				OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V))
		AND GR.GeoRefID NOT IN(
				SELECT ISNULL(WC.V.value('text()[1]', 'nvarchar(max)'), '') AS city
				FROM cust.tblRli AS R
				INNER JOIN cust.tblRLIMap RM ON R.RLIID = RM.RLIID
				AND RM.ConfigurationID = @configurationId
				OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V))
	END
	ELSE IF (@viewName = 'timezone')
	BEGIN
		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.tblGeoRef GR
		INNER join dbo.tblGeoRefMap GRM ON 
		GR.ID = GRM.GeoRefID and GRM.ConfigurationID = @configurationId
		WHERE GR.isTimeZonePoi = 1 AND
		GR.GeoRefID NOT IN (SELECT ISNULL(TZV.V.value('text()[1]', 'nvarchar(max)'), '') AS city
            FROM cust.tblWorldTimeZonePlaceNames AS TZ
            INNER JOIN cust.tblWorldTimeZonePlaceNamesMap TZM ON TZ.PlaceNameID = TZM.PlaceNameID
            AND TZM.ConfigurationID = @configurationId
            OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZV(V))
	END
	ELSE IF (@viewName = 'worldclock')
	BEGIN

		SET @DepartureXML	= (SELECT WC.WorldClockCities
						FROM cust.tblWorldClockCities AS WC
						INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
						AND WCM.ConfigurationID = @configurationId
						WHERE WC.WorldClockCities.exist('/worldclock_cities/city[@name = "Departure"]') = 1)
		SET @DestinationXML = (SELECT WC.WorldClockCities
					FROM cust.tblWorldClockCities AS WC
					INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
					AND WCM.ConfigurationID = @configurationId
					WHERE WC.WorldClockCities.exist('/worldclock_cities/default_city[@name = "Departure"]') = 1)

		IF (@DepartureXML IS NULL AND @DestinationXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		END

		SET @DepartureXML	= (SELECT WC.WorldClockCities
					FROM cust.tblWorldClockCities AS WC
					INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
					AND WCM.ConfigurationID = @configurationId
					WHERE WC.WorldClockCities.exist('/worldclock_cities/city[@name = "Destination"]') = 1)
		SET @DestinationXML	= (SELECT WC.WorldClockCities
					FROM cust.tblWorldClockCities AS WC
					INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
					AND WCM.ConfigurationID = @configurationId
					WHERE WC.WorldClockCities.exist('/worldclock_cities/default_city[@name = "Destination"]') = 1)

		IF (@DepartureXML IS NULL AND @DestinationXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		END

		SET @cityXML = (SELECT WC.WorldClockCities
						FROM cust.tblWorldClockCities AS WC
						INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
						AND WCM.ConfigurationID = @configurationId
						WHERE WC.WorldClockCities.exist('/worldclock_cities/city') = 1)

		IF (@cityXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.tblGeoRef GR
			INNER join dbo.tblGeoRefMap GRM ON 
			GR.ID = GRM.GeoRefID and GRM.ConfigurationID = @configurationId
			WHERE GR.isWorldClockPoi = 1 AND
			Description NOT IN (SELECT
				WCL.V.value('@geoRef', 'nvarchar(max)') AS city
				FROM cust.tblWorldClockCities AS WC
				INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
				AND WCM.ConfigurationID = @configurationId
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V))
		END
		ELSE IF (@cityXML IS NOT NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.tblGeoRef GR
			INNER join dbo.tblGeoRefMap GRM ON 
			GR.ID = GRM.GeoRefID and GRM.ConfigurationID = @configurationId
			WHERE GR.isWorldClockPoi = 1 AND
			GR.GeoRefID NOT IN (SELECT
				ISNULL(WCL.V.value('@geoRef', 'nvarchar(max)'), '') AS city
				FROM cust.tblWorldClockCities AS WC
				INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
				AND WCM.ConfigurationID = @configurationId
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)) AND
			GR.GeoRefID NOT IN (SELECT
				ISNULL(WCL.V.value('@geoRef', 'nvarchar(max)'), '') AS city
				FROM cust.tblWorldClockCities AS WC
				INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
				AND WCM.ConfigurationID = @configurationId
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V))
		END
	END

	SELECT * FROM @tmpTable
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Select and Update command to move particular view location
-- Sample EXEC [dbo].[SP_Views_MoveSelectedView] 18, 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_MoveSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_MoveSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_MoveSelectedView]
@configurationId INT,
@type NVARCHAR(150),
@xmlValue XML = NULL
AS
BEGIN
	IF (@type = 'get')
		BEGIN
			SELECT perspective as xmlData FROM
			cust.tblMenu M INNER JOIN Cust.tblMenuMap MM ON
			M.MenuId = MM.MenuID AND MM.ConfigurationId = @configurationId
		END
	ELSE IF (@type = 'update')
		BEGIN
			UPDATE M
            SET perspective = @xmlValue FROM cust.tblMenu M
			INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID AND MM.ConfigurationID = @configurationId
			SELECT 1 AS returnValue
		END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Updates selected view enable status
-- Sample EXEC EXEC [dbo].[SP_Views_UpdateSelectedView] 18, 'Landscape', 'true'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_UpdateSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_UpdateSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_UpdateSelectedView]
@configurationId INT,
@viewName NVARCHAR(500),
@updateValue NVARCHAR(200)
AS
BEGIN
	DECLARE @count INT, @xmlData INT

	SET @count = (SELECT CONVERT (INT, CONVERT(VARCHAR(MAX),FS.Value)) FROM tblFeatureSet FS 
        INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
        INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        WHERE FS.Name = 'views-max-presets' AND C.ConfigurationID = @configurationId)

    SELECT @xmlData = COUNT(ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), ''))
        FROM cust.tblMenu M
        INNER JOIN cust.tblMenuMap MM ON M.MenuID = MM.MenuID
        AND MM.ConfigurationID = @configurationId
        CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
        WHERE Nodes.item.value('(./@quick_select)[1]', 'varchar(max)') = 'true'
	IF (@updateValue = 'true')
	BEGIN
		IF (@count > @xmlData)
		BEGIN
            UPDATE M 
            SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")') 
            FROM cust.tblMenu M 
            INNER JOIN cust.tblmenumap MM on m.menuid = MM.menuid and mm.ConfigurationID =  @configurationId 
            WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true'

			SELECT 1 AS returnValue
		END
		ELSE
		BEGIN
			SELECT 2 AS returnValue
		END
	END
	ELSE
	BEGIN
		UPDATE M 
            SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")') 
            FROM cust.tblMenu M 
            INNER JOIN cust.tblmenumap MM on m.menuid = MM.menuid and mm.ConfigurationID =  @configurationId 
			WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true'
			
			SELECT 1 AS returnValue
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add new alternate world clock locations
-- Sample EXEC [dbo].[SP_WorldClock_AddAlternateWorldClockCity] 18, '9', 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_AddAlternateWorldClockCity]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_AddAlternateWorldClockCity]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_AddAlternateWorldClockCity]
@configurationId INT,
@inputGeoRefId NVARCHAR(500),
@type NVARCHAR(150),
@xmlValue xml = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @cityName NVARCHAR(250), @worldClockCities XML
		DECLARE @temp TABLE(xmlData XML, cityName NVARCHAR(250))

		IF (@inputGeoRefId = '-1')
		BEGIN
			SET @cityName = 'Departure'
		END
		ELSE IF (@inputGeoRefId = '-2')
		BEGIN
			SET @cityName = 'Destination'
		END
		ELSE
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.tblgeoref GR
			INNER join dbo.tblGeoRefMap GRM ON 
			GR.Id = GRM.GeoRefID and GRM.ConfigurationID = @configurationId 
			WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId
			AND GR.Description not IN (
					SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.tblWorldClockCities AS WC
					INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
					AND WCM.ConfigurationID = @configurationId
					OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
			AND GR.Description not IN(
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.tblWorldClockCities AS W
					INNER JOIN cust.tblWorldClockCitiesMap WCM ON W.WorldClockCityID = WCM.WorldClockCityID
					AND WCM.ConfigurationID = @configurationId
					OUTER APPLY W.WorldClockCities.nodes('worldclock_cities/default_city')  AS WC(V)))
		END

		IF (@cityName IS NOT NULL AND @cityName != '')
		BEGIN
			SET @worldClockCities =(SELECT WC.WorldClockCities AS xmlData 
            FROM cust.tblWorldClockCities AS WC
            INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
            AND WCM.ConfigurationId = @configurationId)

			INSERT INTO @temp VALUES (@worldClockCities, @cityName)

			SELECT * FROM @temp
		END
	END
	ELSE IF (@type = 'update')
	BEGIN
		UPDATE WC
		SET WorldClockCities = @xmlValue FROM cust.tblWorldClockCities WC
		INNER JOIN CUST.tblWorldClockCitiesMap WCM
		ON WC.WorldClockCityID = WCM.WorldClockCityID AND WCM.ConfigurationID = @ConfigurationId

		SELECT 1 AS retValue
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get availavle and alternate world clock locations
-- Sample EXEC EXEC EXEC [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations] 18, 'alternate'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]
@configurationId INT,
@type NVARCHAR(150)
AS
BEGIN
	IF (@type = 'available')
	BEGIN
		SELECT WCL.V.value('@name', 'nvarchar(max)') AS city,
        WCL.V.value('@geoRef', 'nvarchar(max)') AS geoRefId
        FROM cust.tblWorldClockCities AS WC
        INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
        AND WCM.ConfigurationID = @configurationId
        OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)
	END
	
	ELSE IF (@type = 'alternate')
	BEGIN
		SELECT WCL.V.value('@name', 'nvarchar(max)') AS city,
        WCL.V.value('@geoRef', 'nvarchar(max)') AS geoRefId
        FROM cust.tblWorldClockCities AS WC
        INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
        AND WCM.ConfigurationID = @configurationId
        OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and update the xml data for the Worldclock
-- Sample EXEC [dbo].[SP_WorldClock_MoveWorldclockLocation] 18, 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_MoveWorldclockLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_MoveWorldclockLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_MoveWorldclockLocation]
@configurationId INT,
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT WC.WorldClockCities AS xmlData 
        FROM cust.tblWorldClockCities AS WC
        INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
        AND WCM.ConfigurationId = @configurationId
	END
	ELSE IF (@type = 'update' AND @xmlData IS NOT NULL)
	BEGIN
		BEGIN TRY
			UPDATE WC
			SET WorldClockCities = @xmlData FROM cust.tblWorldClockCities AS WC
			INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
			AND WCM.ConfigurationId = @configurationId

			SELECT 1 AS retValue
		END TRY
		BEGIN CATCH
			SELECT 0 AS retValue
		END CATCH
	END
	ELSE
	BEGIN
		SELECT 0 AS retValue
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add or remove available world clock locations
-- Sample EXEC [dbo].[SP_WorldClock_UpdateWorldclockLocation] 18, '9,25', 'add'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_UpdateWorldclockLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_UpdateWorldclockLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_UpdateWorldclockLocation]
@configurationId INT,
@InputList NVARCHAR(500),
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(Descriptions NVARCHAR(500), id INT)
	DECLARE @xmlData XML, @tmpxml XML, @currentXML XML, @data NVARCHAR(250), @geoRefID NVARCHAR(150)
	DECLARE @retTable TABLE (id INT)
	DECLARE @cityXML XML

	SET @xmlData = (SELECT WorldClockCities as xmlData FROM cust.tblWorldClockCities WC
                    INNER JOIN cust.tblWorldClockCitiesMap WCM 
                    ON WC.WorldClockCityID = WCM.WorldClockCityID and WCM.ConfigurationID = @configurationId)

	IF (@type = 'add')
	BEGIN
		SET @cityXML = (SELECT GR.Description FROM dbo.tblGeoRef GR
		INNER join dbo.tblGeoRefMap GRM ON 
		GR.Id = GRM.GeoRefID and GRM.ConfigurationID = @configurationId 
		WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description NOT IN (
			SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
			FROM cust.tblWorldClockCities AS WC
			INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
			AND WCM.ConfigurationID = @configurationId
			OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)))
			
		IF (@cityXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.tblgeoref GR
			INNER join dbo.tblGeoRefMap GRM ON 
			GR.Id = GRM.GeoRefID and GRM.ConfigurationID = @configurationId 
			WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		END
		ELSE IF (@cityXML IS NOT NULL)
		BEGIN
			INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.tblgeoref GR
			INNER join dbo.tblGeoRefMap GRM ON 
			GR.Id = GRM.GeoRefID and GRM.ConfigurationID = @configurationId 
			WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
			AND GR.Description NOT IN (
				SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.tblWorldClockCities AS WC
				INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
				AND WCM.ConfigurationID = @configurationId
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
		END
	END
	ELSE IF (@type = 'remove')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.tblgeoref GR
		INNER join dbo.tblGeoRefMap GRM ON 
		GR.Id = GRM.GeoRefID and GRM.ConfigurationID = @configurationId 
		WHERE GR.isWorldClockPoi = 1 AND  GR.GeoRefId IN (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description IN (
			SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
			FROM cust.tblWorldClockCities AS WC
			INNER JOIN cust.tblWorldClockCitiesMap WCM ON WC.WorldClockCityID = WCM.WorldClockCityID
			AND WCM.ConfigurationID = @configurationId
			OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
	END

	SET @currentXML = (SELECT W.WorldClockCities FROM cust.tblWorldClockCities AS W
    INNER JOIN cust.tblWorldClockCitiesMap WCM ON W.WorldClockCityID = WCM.WorldClockCityID
    AND WCM.ConfigurationID = @ConfigurationId)

	IF (@type = 'all')
	BEGIN
		SET @currentXML.modify('delete /worldclock_cities/city')
	
		BEGIN TRY
			UPDATE W
			SET W.WorldClockCities = @currentXML
			FROM cust.tblWorldClockCities W
			INNER JOIN CUST.tblWorldClockCitiesMap WM
			ON W.WorldClockCityID = WM.WorldClockCityID AND WM.ConfigurationID = @ConfigurationId
			INSERT INTO @retTable(id) VALUES (1)
		END TRY
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
	END

	IF CHARINDEX('-1', @InputList) > 0
	BEGIN
		INSERT INTO @tmpTable (id, Descriptions) VALUES('-1', 'Departure')
	END
	IF CHARINDEX('-2', @InputList) > 0
	BEGIN
		INSERT INTO @tmpTable (id, Descriptions) VALUES('-2', 'Destination')
	END

	WHILE (SELECT Count(*) FROM @tmpTable) > 0
	BEGIN
		SET @data = (SELECT TOP 1 Descriptions FROM @tmpTable)
		SET @geoRefID = (SELECT TOP 1 id FROM @tmpTable)
		
		IF (@type = 'add')
		BEGIN
			SET @tmpxml = ('<city name="'+ @data +'" geoRef="'+ @geoRefID +'" />')
			SET @currentXML.modify('insert sql:variable("@tmpxml")into (worldclock_cities)[1]')
		END
		ELSE IF (@type = 'remove')
		BEGIN
			SET @currentXML.modify('delete /worldclock_cities/city[@geoRef = sql:variable("@geoRefID")]')
		END
		BEGIN TRY
		UPDATE W
			SET W.WorldClockCities = @currentXML
			FROM cust.tblWorldClockCities W
			INNER JOIN CUST.tblWorldClockCitiesMap WM
			ON W.WorldClockCityID = WM.WorldClockCityID AND WM.ConfigurationID = @ConfigurationId
			INSERT INTO @retTable(id) VALUES (1)
		END TRY
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
		DELETE @tmpTable WHERE Id = @geoRefID
	END
	SELECT id FROM @retTable
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 3/15/2022
-- Description:	Gets XML value from different custom tables
-- Sample EXEC [cust].[SP_GetXML] 18 , 'webmain'
-- =============================================

IF OBJECT_ID('[cust].[SP_GetXML]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_GetXML]
END
GO

CREATE PROCEDURE [cust].[SP_GetXML]
	@configurationId INT,
    @section NVARCHAR(250)
AS
BEGIN

	IF (@section = 'flyoveralerts')
	BEGIN
		SELECT FlyOverAlert as XMLValue
        FROM cust.tblFlyOverAlert
        INNER JOIN cust.tblFlyOverAlertMap ON cust.tblFlyOverAlertMap.FlyOverAlertID = cust.tblFlyOverAlert.FlyOverAlertID
        WHERE cust.tblFlyOverAlertMap.ConfigurationID = @configurationId
	END
    ELSE IF (@section = 'webmain')
	BEGIN
        SELECT WebMainItems as XMLValue
        FROM cust.tblWebMain
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
        WHERE cust.tblWebMainMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'global')
	BEGIN
        SELECT cust.tblGlobal.Global as XMLValue
        FROM cust.tblGlobal
        INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID
        WHERE cust.tblGlobalMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'maps')
	BEGIN
        SELECT MapItems as XMLValue
        FROM cust.tblMaps
        INNER JOIN cust.tblMapsMap ON cust.tblMapsMap.MapID = cust.tblMaps.MapID
        WHERE cust.tblMapsMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'layers')
	BEGIN
        SELECT Layers as XMLValue
        FROM cust.tblMenu as Menu 
        INNER JOIN cust.tblMenuMap ON cust.tblMenuMap.MenuID = Menu.MenuID 
        WHERE cust.tblMenuMap.ConfigurationID = @configurationId
    END
END
GO
GO

-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 1/28/2022
-- Description:	The procedure is used to add new mapinsets to tblASXiInset
-- The inputs are MapInsetName,ZoomLevel,MapInsetsPath and MapPackageType
---execute SP_Insets_Add 'Beijing', 3.75, 'test/Beijing.zip','LandSat7',364,369,1432,1437,38.12211,37.69572,23.74508,24.17147,false,'<![CDATA[
---FC 00 00 00 FC 00 00 00 FC 00 00 00 F8 00 00 00 3C 00 00 00 A4 00 00 00]]>';
-- =============================================
IF OBJECT_ID('[dbo].[SP_Insets_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Insets_Add]
END
GO

CREATE PROCEDURE [dbo].[SP_Insets_Add]
	 @MapInsetName nvarchar(50),
	 @ZoomLevel float,
	 @MapInsetsPath nvarchar(max),
	 @MapPackageType nvarchar(50),
	 @RowStart int,
	 @RowEnd int,
	 @ColStart int,
	 @ColEnd int,
	 @LatStart float,
	 @LatEnd float,
	 @LongStart float,
	 @LongEnd float,
	 @IsHf bit,
	 @Cdata nvarchar(max)
AS
BEGIN
	BEGIN
		DECLARE @retTable TABLE (message NVARCHAR(250))
		BEGIN TRY
			BEGIN TRANSACTION
				INSERT INTO [dbo].[tblASXiInset] (InsetName,Zoom,Path,MapPackageType,RowStart,RowEnd,ColStart,ColEnd,LatStart,LatEnd,LongStart,LongEnd,IsHf,Cdata)
				VALUES
				(@MapInsetName,@ZoomLevel,@MapInsetsPath,@MapPackageType,@RowStart,@RowEnd,@ColStart,@ColEnd,@LatStart,@LatEnd,@LongStart,@LongEnd,@IsHf,@Cdata);
			COMMIT
			INSERT INTO @retTable(message) VALUES ('Success')
		END TRY
		BEGIN CATCH
			INSERT INTO @retTable(message) VALUES ('Failure')
		END CATCH
		SELECT * FROM @retTable
	END	
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 1/28/2022
-- Description:	Populates tblASXiInsetMap table based on the data present in dbo.tblMapInsets and dbo.tblASXiInset.
-- Scans the Temdescription.xml. For every inset in the xml, tries to finds a match in the inset catalog in dbo.tblASXiInset. If one found, creates the mapping in the dbo.tblMapInsetsMap. 
-- If not, creates a new entry in the inset catalog before updating the dbo.tblMapInsetsMap. 
-- Parameters: ConfigurationId
-- Sample EXEC [dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap] 1
-- =============================================


IF OBJECT_ID('[dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap]
END
GO

CREATE PROCEDURE [dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap]
	@configurationId int

AS
BEGIN

    -- Get the current MapPackageType from custom.xml in the cust.tblMaps table.
    DECLARE  @resolution FLOAT,
    @mapPackagetype VARCHAR(20)
    SET @mapPackagetype =  (SELECT 
                            CASE WHEN LOWER(MapTable.MapPackageType) = 'temlandsat7' THEN 'landsat7' 
                                WHEN LOWER(MapTable.MapPackageType) = 'temnaturalvue' THEN 'landsat8' 
                            END as MapPackageType
                            FROM
                            (   SELECT
                                MapItems.value('(/maps/map_package/text())[1]', 'varchar(max)') as MapPackageType
                                FROM cust.tblMaps 
                                INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
                                AND cust.tblMapsMap.ConfigurationID = @configurationId
                            ) as MapTable
                            );

       

    -- Delete the existing entries in the dbo.tblASXiInsetMap table for the configuration id to avoid duplicate inserts.
    BEGIN TRANSACTION
        DELETE FROM dbo.tblASXiInsetMap
        WHERE dbo.tblASXiInsetMap.ConfigurationID = @configurationId;
    COMMIT

    -- use the "res" attribute from TemDescription.xml file as cursor to scan through the insets in the xml.
    DECLARE cursor_res CURSOR
    FOR
    SELECT 
    isnull(Nodes.Insets.value('(./@res)[1]', 'varchar(max)'),'') as Resolution
    FROM dbo.tblMapInsets as M
    cross apply M.MapInsets.nodes('/tem_map_package/tem') as Nodes(Insets)
    INNER JOIN dbo.tblMapInsetsMap ON dbo.tblMapInsetsMap.MapInsetsID = M.MapInsetsID
    WHERE dbo.tblMapInsetsMap.ConfigurationID = @configurationId;


    OPEN cursor_res;

    FETCH NEXT FROM cursor_res INTO @resolution;

    WHILE @@FETCH_STATUS = 0

        BEGIN

            -- Find the insets in the xml which do not match any row in Original inset catalog from dbo.tblASXiInset.
            -- For those insets which do not have a match, insert the inset data onto the dbo.tblASXiInset table before creating a mapping in dbo.tblASXiInsetMap.
            BEGIN TRANSACTION

                MERGE dbo.tblASXiInset AS ASXiInset

                USING ( SELECT M.MapInsetsID,
                isnull(Nodes.Insets.value('(./@name)[1]', 'varchar(max)'),'') as InsetName,
                @resolution as Zoom,
                null as Path,/* considered path as null for now.*/
                @mapPackagetype as MapPackageType,
                isnull(Nodes.Insets.value('(./@row_st)[1]', 'varchar(max)'),'') as RowStart,
                isnull(Nodes.Insets.value('(./@row_end)[1]', 'varchar(max)'),'') as RowEnd,
                isnull(Nodes.Insets.value('(./@col_st)[1]', 'varchar(max)'),'') as ColStart,
                isnull(Nodes.Insets.value('(./@col_end)[1]', 'varchar(max)'),'') as ColEnd,
                isnull(Nodes.Insets.value('(./@lat_st)[1]', 'varchar(max)'),'') as LatStart,
                isnull(Nodes.Insets.value('(./@lat_end)[1]', 'varchar(max)'),'') as LatEnd,
                isnull(Nodes.Insets.value('(./@lon_st)[1]', 'varchar(max)'),'') as LongStart,
                isnull(Nodes.Insets.value('(./@lon_end)[1]', 'varchar(max)'),'') as LongEnd,
                CASE WHEN Nodes.Insets.value('(./@is_hf)[1]', 'varchar(max)') = 'true' THEN 1 ELSE 0 END AS IsHf,
                isnull(Nodes.Insets.value('(./@partNum)[1]', 'varchar(max)'),'') as PartNumber,
                isnull(Nodes.Insets.value('(./text())[1]', 'varchar(max)'),'') as Cdata
                FROM dbo.tblMapInsets as M
                cross apply M.MapInsets.nodes('/tem_map_package/tem[@res =  sql:variable("@resolution")]/insets/inset') as Nodes(Insets) 
                INNER JOIN dbo.tblMapInsetsMap ON dbo.tblMapInsetsMap.MapInsetsID = M.MapInsetsID
                WHERE dbo.tblMapInsetsMap.ConfigurationID = @configurationId)	AS MapInset

                ON (
                        (ASXiInset.ColStart = MapInset.ColStart AND
                        ASXiInset.ColEnd = MapInset.ColEnd AND
                        ASXiInset.RowStart = MapInset.RowStart AND
                        ASXiInset.RowEnd = MapInset.RowEnd)
                    OR 
                        (ASXiInset.LatStart = MapInset.LatStart AND
                        ASXiInset.LatEnd = MapInset.LatEnd AND
                        ASXiInset.LongStart = MapInset.LongStart AND
                        ASXiInset.LongEnd = MapInset.LongEnd)
                    OR 
                        (LOWER(ASXiInset.InsetName) = LOWER(MapInset.InsetName))

                )
                WHEN NOT MATCHED BY TARGET THEN
                    INSERT (InsetName,Zoom, Path,MapPackageType,RowStart,RowEnd,ColStart,ColEnd,LatStart,LatEnd,LongStart,LongEnd,IsHf,PartNumber,Cdata) 
                    VALUES (InsetName,Zoom, Path,MapPackageType,RowStart,RowEnd,ColStart,ColEnd,LatStart,LatEnd,LongStart,LongEnd,IsHf,PartNumber,Cdata);



            -- Insert the ConfigurationID and ASXiInsetID From dbo.tblASXiInset onto dbo.tblASXiInsetMap table to create the mapping.
            -- considered Zoomlevel/resolution and map packge type to Match the correct inset along with Data of Column, Row, Lattitude, Longitude  and Inset Name, in the same order.

                INSERT INTO dbo.tblASXiInsetMap (ConfigurationID,ASXiInsetID,PreviousASXiInsetID,IsDeleted,LastModifiedBy,Action)
                SELECT dbo.tblMapInsetsMap.ConfigurationID as ConfigurationID,
                ASXiInset.ASXiInsetID as ASXiInsetID,
                null as PreviousASXiInsetID,
                0 as IsDeleted,
                null as LastModifiedBy,
                null as Action

                FROM 
                dbo.tblASXiInset as ASXiInset
                INNER JOIN 
                (SELECT M.MapInsetsID,
                isnull(Nodes.Insets.value('(./@name)[1]', 'varchar(max)'),'') as Name,
                isnull(Nodes.Insets.value('(./@col_end)[1]', 'varchar(max)'),'') as ColumnEnd,
                isnull(Nodes.Insets.value('(./@col_st)[1]', 'varchar(max)'),'') as ColumnStart,
                isnull(Nodes.Insets.value('(./@row_end)[1]', 'varchar(max)'),'') as RowEnd,
                isnull(Nodes.Insets.value('(./@row_st)[1]', 'varchar(max)'),'') as RowStart,
                isnull(Nodes.Insets.value('(./@lat_st)[1]', 'varchar(max)'),'') as LatStart,
                isnull(Nodes.Insets.value('(./@lat_end)[1]', 'varchar(max)'),'') as LatEnd,
                isnull(Nodes.Insets.value('(./@lon_st)[1]', 'varchar(max)'),'') as LonStart,
                isnull(Nodes.Insets.value('(./@lon_end)[1]', 'varchar(max)'),'') as LonEnd
                FROM dbo.tblMapInsets as M
                cross apply M.MapInsets.nodes('/tem_map_package/tem[@res =  sql:variable("@resolution")]/insets/inset') as Nodes(Insets) 
                INNER JOIN dbo.tblMapInsetsMap ON dbo.tblMapInsetsMap.MapInsetsID = M.MapInsetsID
                WHERE dbo.tblMapInsetsMap.ConfigurationID = @configurationId
                ) as MapInset 
                ON (
                        (ASXiInset.ColStart = MapInset.ColumnStart AND
                        ASXiInset.ColEnd = MapInset.ColumnEnd AND
                        ASXiInset.RowStart = MapInset.RowStart AND
                        ASXiInset.RowEnd = MapInset.RowEnd)
                    OR 
                        (ASXiInset.LatStart = MapInset.LatStart AND
                        ASXiInset.LatEnd = MapInset.LatEnd AND
                        ASXiInset.LongStart = MapInset.LonStart AND
                        ASXiInset.LongEnd = MapInset.LonEnd)
                    OR 
                        (LOWER(ASXiInset.InsetName) = LOWER(MapInset.Name))

                )
                INNER JOIN dbo.tblMapInsetsMap ON MapInset.MapInsetsID = dbo.tblMapInsetsMap.MapInsetsID
                INNER JOIN (SELECT 
                            CASE WHEN LOWER(MapTable.MapPackageType) = 'temlandsat7' THEN 'landsat7' 
                                WHEN LOWER(MapTable.MapPackageType) = 'temnaturalvue' THEN 'landsat8' 
                            END as MapPackageType
                            FROM
                            (   SELECT
                                MapItems.value('(/maps/map_package/text())[1]', 'varchar(max)') as MapPackageType
                                FROM cust.tblMaps 
                                INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
                                AND cust.tblMapsMap.ConfigurationID = @configurationId
                            ) as MapTable)  as Map ON LOWER(Map.MapPackageType) = LOWER(ASXiInset.MapPackageType)
                WHERE ASXiInset.Zoom = @resolution AND dbo.tblMapInsetsMap.ConfigurationID = @configurationId;
            COMMIT


            FETCH NEXT FROM cursor_res INTO  @resolution;

        END;
    CLOSE cursor_res;
    DEALLOCATE cursor_res;	
END
GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Adds a trigger record to the specified configuration.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Add]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Add]
	@configurationId int,
	@id int,
	@name varchar(max),
	@type varchar(max),
	@condition varchar(max),
	@default varchar(max)
AS
BEGIN
	set nocount on

	-- check for and  create a trigger record if one is not present for the configuration
	-- this should never occur because the flow down from the global configuration should always have a record,
	-- but just in case!!!
    declare @triggerId int
	set @triggerId = (select triggerId from tblTriggerMap where ConfigurationID = @configurationId)

	if @triggerId is null
	begin
		exec cust.SP_Trigger_New @triggerId = @triggerId output
		exec dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblTrigger', @triggerId
	end

	-- create and add the trigger node to the configuration
	--
	declare @triggerDefinition varchar(max) =
		'<trigger condition="' + @condition + '" default="' + @default + '" id="' + cast(@id as varchar) + '" name="' + @name + '" type="' + @type + '"/>'
	declare @triggerNode xml = cast(@triggerDefinition as xml)

	set nocount off
	update cust.tblTrigger
	set TriggerDefs.modify('insert sql:variable("@triggerNode") into /trigger_defs[1]')
	where cust.tblTrigger.TriggerID = @triggerId;

END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/17/2022
-- Description:	Removes a trigger from the trigger configuration associated with the specified
--   configuration id. If no trigger record is present, then no action is taken.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Delete]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Delete]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Delete]
	@configurationId int,
	@triggerId int
AS
BEGIN
	set nocount on
	declare @mappedTriggerId int = (select triggerId from tblTriggerMap where configurationId = @configurationId)

	-- if there is a trigger defined for this configuration then attempt to remove the specified
	-- trigger
	if not @mappedTriggerId is null
	begin
		declare @updateKey int
		exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblTrigger', @mappedTriggerId, @updateKey out

		set nocount off
		update cust.tblTrigger
		set TriggerDefs.modify('delete /trigger_defs/trigger[@id = sql:variable("@triggerId")]')
		where TriggerID = @updateKey
	end
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Returns a single trigger from a configuration. The XML is decomposed in to individual fields of a record.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Get]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Get]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Get]
	@configurationId int,
	@triggerId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		isnull(Nodes.TriggerItem.value('(./@name)[1]', 'varchar(max)'),'') as Name, 
		isnull(Nodes.TriggerItem.value('(./@condition)[1]', 'varchar(max)'),'') as Condition, 
		isnull(Nodes.TriggerItem.value('(./@id)[1]', 'varchar(max)'),'') as Id, 
		isnull(Nodes.TriggerItem.value('(./@type)[1]', 'varchar(max)'),'') as Type, 
		isnull(Nodes.TriggerItem.value('(./@default)[1]', 'varchar(max)'),'false') as IsDefault 
	FROM cust.tblTrigger as T 
		cross apply T.TriggerDefs.nodes('/trigger_defs/trigger[@id = sql:variable("@triggerId")]') as Nodes(TriggerItem)
		INNER JOIN cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID AND cust.tblTriggerMap.ConfigurationID = @configurationId and cust.tblTriggerMap.IsDeleted = 0
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Retrieves all triggers in the trigger xml element for a specific configuration.
--   Each trigger element is returned as a separate record
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_GetAll]
END
GO
CREATE PROCEDURE [cust].[SP_Trigger_GetAll]
	@configurationId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		isnull(Nodes.TriggerItem.value('(./@name)[1]', 'varchar(max)'),'') as Name,
		isnull(Nodes.TriggerItem.value('(./@condition)[1]', 'varchar(max)'),'') as Condition,
		isnull(Nodes.TriggerItem.value('(./@id)[1]', 'varchar(max)'),'') as Id,
		isnull(Nodes.TriggerItem.value('(./@type)[1]', 'varchar(max)'),'') as Type,
		isnull(Nodes.TriggerItem.value('(./@default)[1]', 'varchar(max)'),'false') as IsDefault
	FROM cust.tblTrigger as T
		cross apply T.TriggerDefs.nodes('/trigger_defs/trigger') as Nodes(TriggerItem)
		inner join cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID 
			and cust.tblTriggerMap.ConfigurationID = @configurationId
			and cust.tblTriggerMap.IsDeleted = 0
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Creates a new trigger record with the default trigger xml element in place.
--   The newly created trigger id is returned as an output parameter
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_New]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_New]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_New]
	@triggerId int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @triggerIds table (TriggerId int)
    INSERT INTO cust.tblTrigger
		(TriggerDefs)
	OUTPUT inserted.TriggerId into @triggerIds
	VALUES('<trigger_defs/>')

	set @triggerId = scope_identity()
END

GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 3/15/2022
-- Description:	Updates XML of different custom tables
-- Sample EXEC [cust].[SP_UpdateXML] 18 , 'webmain', 'xml value'
-- =============================================

IF OBJECT_ID('[cust].[SP_UpdateXML]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_UpdateXML]
END
GO

CREATE PROCEDURE [cust].[SP_UpdateXML]
	@configurationId INT,
    @section NVARCHAR(250),
    @xmlValue xml
AS
BEGIN

	IF (@section = 'flyoveralerts')
	BEGIN

        UPDATE cust.tblFlyOverAlert
        SET FlyOverAlert = @xmlValue
        WHERE cust.tblFlyOverAlert.FlyOverAlertID IN (
	                SELECT distinct cust.tblFlyOverAlertMap.FlyOverAlertID FROM cust.tblFlyOverAlertMap
	                WHERE cust.tblFlyOverAlertMap.ConfigurationID = @configurationId
	                )
	END
    ELSE IF (@section = 'webmain')
	BEGIN

        UPDATE cust.tblWebMain
        SET WebMainItems = @xmlValue
        WHERE cust.tblWebMain.WebMainID IN (
	                SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap
	                WHERE cust.tblWebMainMap.ConfigurationID = @configurationId
	                )
       
    END
    ELSE IF (@section = 'global')
	BEGIN
    
        UPDATE cust.tblGlobal
        SET cust.tblGlobal.Global = @xmlValue
        WHERE cust.tblGlobal.CustomID IN (
	                SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap
	                WHERE cust.tblGlobalMap.ConfigurationID = @configurationId
	                )
    END
    ELSE IF (@section = 'maps')
	BEGIN
       
        UPDATE cust.tblMaps
        SET MapItems = @xmlValue
        WHERE cust.tblMaps.MapID IN (
	                SELECT distinct cust.tblMapsMap.MapID FROM cust.tblMapsMap
	                WHERE cust.tblMapsMap.ConfigurationID = @configurationId
	                )
    END
    ELSE IF(@section = 'layers')
    BEGIN
        UPDATE cust.tblMenu
        SET Layers = @xmlValue
        WHERE cust.tblMenu.MenuID IN (
	                SELECT distinct cust.tblMenuMap.MenuID FROM cust.tblMenuMap
	                WHERE cust.tblMenuMap.ConfigurationID = @configurationId
	                )
    END
END
GO
GO

