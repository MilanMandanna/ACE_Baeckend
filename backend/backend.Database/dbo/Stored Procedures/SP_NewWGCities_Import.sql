SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 03/25/2022
-- Description:	Import new WG Cities FROM Data Source files,
--				Date 03/31/2022 Laksmikanth Updated the SP to update ConfigurationHistoryTable
-- Sample EXEC [dbo].[SP_NewWGCities_Import] 1, '8435FAA9-7174-4F4D-A1E7-A4C52A020142' , '83A32F91-81A0-49F2-B7E7-47EA335C94DC'
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

	DECLARE @tblTempWGDetailedFlightInfo_toLoop TABLE(ID INT IDENTITY(1,1),DataId INT,GeoRefID INT, Overview NVARCHAR(MAX),Features NVARCHAR(MAX),Sights NVARCHAR(MAX),Stats NVARCHAR(MAX),ImageFileName NVARCHAR(MAX),Text_Description NVARCHAR(MAX))
	DECLARE @tblTempWGCityFlightInfo_toLoop TABLE(ID INT IDENTITY(1,1),DataId INT,ImageFileName NVARCHAR(MAX),DescriptionInLang NVARCHAR(MAX),Language NVARCHAR(250),GeoRefID INT )
	DECLARE @tempWGImage TABLE(ID INT IDENTITY(1,1), FileName NVARCHAR(250))
	DECLARE @tempWGText TABLE(ID INT IDENTITY(1,1) ,Text_Description NVARCHAR(MAX))
	DECLARE @temptextLang TABLE(ID INT IDENTITY(1,1) ,Lang NVARCHAR(50))
	BEGIN

		--Import tblTempWGDetailedFlightInfo to a temp table to loop the entire table
		INSERT INTO @tblTempWGDetailedFlightInfo_toLoop SELECT * FROM tblTempWGDetailedFlightInfo AS TWG WHERE TWG.ImageFileName NOT IN
		(SELECT ImageFileName FROM dbo.tblWGImage WGI INNER JOIN dbo.tblWGImageMap WGIM ON WGI.ID = WGIM.ImageID WHERE WGIM.ConfigurationID =@configid) 

		--Import tblTempWGDetailedFlightInfo to a temp table to loop the entire table
		INSERT INTO @tblTempWGCityFlightInfo_toLoop SELECT * FROM tblTempWGCityFlightInfo AS TWG WHERE TWG.ImageFileName NOT IN
		(SELECT ImageFileName FROM dbo.tblWGImage WGI INNER JOIN dbo.tblWGImageMap WGIM ON WGI.ID = WGIM.ImageID WHERE WGIM.ConfigurationID =@configid) 

		-- Delete the existing entries in the table for the configuration id to avoid duplicate inserts.
		UPDATE dbo.tblWGImageMap
		SET IsDeleted = 1
		WHERE dbo.tblWGImageMap.ConfigurationID = @configid;

		UPDATE dbo.tblWGtextMap
		SET IsDeleted = 1
		WHERE dbo.tblWGtextMap.ConfigurationID = @configid;

		UPDATE dbo.tblWGContentMap
		SET IsDeleted = 1
		WHERE dbo.tblWGContentMap.ConfigurationID = @configid;
		--Processing Rockwell.xml Data
		WHILE(SELECT COUNT(*) FROM @tblTempWGDetailedFlightInfo_toLoop) > 0

			BEGIN
				SET @geoRefId = (SELECT TOP 1 GeoRefID FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempID = (SELECT TOP 1 ID FROM @tblTempWGDetailedFlightInfo_toLoop)


				--Get Data to @tempWGImage for further processing
				INSERT INTO @tempWGImage(FileName)
				SELECT * FROM string_split((SELECT TOP 1 ImageFileName FROM @tblTempWGDetailedFlightInfo_toLoop),'|')
				DELETE @tempWGImage WHERE FileName = ''

				--Get Data to @tempWGText for further processing
				INSERT INTO @tempWGText(Text_Description)
				SELECT * FROM string_split((SELECT TOP 1 Text_Description FROM @tblTempWGDetailedFlightInfo_toLoop),'|')
				DELETE @tempWGText WHERE Text_Description = ''


				BEGIN
					DECLARE @tempID1 INT,@tempID2 INT ;
					WHILE(SELECT COUNT(*) FROM @tempWGImage) > 0
						BEGIN
							SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
							SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
							SET @tempID1 = (SELECT TOP 1  ID FROM @tempWGImage)
							SET @tempID2 = (SELECT TOP 1  ID FROM @tempWGText)
							SET @tempImageID = 1 + @MaxImageID
							SET @tempTextID = 1 + @MaxTextID

							SET @tempImagName = (SELECT TOP 1 FileName FROM @tempWGImage)
							SET @temptextName = (SELECT TOP 1 Text_Description FROM @tempWGText)

							--Insert tblWGImage Table and and its Maping Table
							DECLARE @WGImageId INT;
							INSERT INTO dbo.tblWGImage(ImageID,FileName)
							VALUES(@tempImageID,@tempImagName);
							SET @WGImageId = SCOPE_IDENTITY()
							EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGImage', @WGImageId  

							--Insert tblWGtext Table and and its Maping Table
							DECLARE @WGTextId INT;
							INSERT INTO dbo.tblWGtext(TextID,Text_EN)
							VALUES(@tempTextID,@temptextName);
							SET @WGTextId = SCOPE_IDENTITY()
							EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextId  

							--Insert tblWGContent Table and and its Maping Table
							DECLARE @WGContentId INT;
							INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
							VALUES(@geoRefId,1,@tempImageID,@tempTextID);
							SET @WGContentId = SCOPE_IDENTITY()
							EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGContentId  

							DELETE @tempWGImage WHERE ID = @tempID1
							DELETE @tempWGText WHERE ID = @tempID2

					END
				END
				--Update tblWGText and tblWGContent which does'nt have images but having text
				--Updated the table With Overview Data
				SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
				SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)

				SET @temptextName = (SELECT TOP 1 Overview FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = 1 + @MaxTextID
					
				--Insert tblWGtext Table and and its Maping Table
				DECLARE @WGTextOverviewId INT;
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName);
				SET @WGTextOverviewId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextOverviewId  

				--Insert tblWGContent Table and and its Maping Table
				DECLARE @WGOverviewContentId INT;
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,1,-1,@tempTextID);
				SET @WGContentId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGOverviewContentId  

				--Updated the table With Features Data
				SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
				SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
				SET @temptextName = (SELECT TOP 1 Features FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = 1 + @MaxTextID

				--Insert tblWGtext Table and and its Maping Table
				DECLARE @WGTextFeaturesId INT;
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName);
				SET @WGTextFeaturesId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextFeaturesId  

				--Insert tblWGContent Table and and its Maping Table
				DECLARE @WGFeaturesContentId INT;
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,3,-1,@tempTextID);
				SET @WGFeaturesContentId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGFeaturesContentId  

				--Updated the table With Sights Data
				SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
				SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
				SET @temptextName = (SELECT TOP 1 Sights FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = 1 + @MaxTextID

				--Insert tblWGtext Table and and its Maping Table
				DECLARE @WGTextSightsId INT;
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName);
				SET @WGTextSightsId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextSightsId  

				--Insert tblWGContent Table and and its Maping Table
				DECLARE @WGSightsContentId INT;
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,4,-1,@tempTextID);
				SET @WGSightsContentId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGSightsContentId  

				--Updated the table With Stats Data
				SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
				SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
				SET @temptextName = (SELECT TOP 1 Stats FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = 1 + @MaxTextID

				--Insert tblWGtext Table and and its Maping Table
				DECLARE @WGTextStatsId INT;
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName);
				SET @WGTextSightsId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextStatsId  

				--Insert tblWGContent Table and and its Maping Table
				DECLARE @WGStatsContentId INT;
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,2,-1,@tempTextID);
				SET @WGStatsContentId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGStatsContentId  

				DELETE @tblTempWGDetailedFlightInfo_toLoop WHERE Id = @tempID
		END


		--Processing flight_POI.xml Data
		DELETE @tempWGText
		WHILE(SELECT COUNT(*) FROM @tblTempWGCityFlightInfo_toLoop) > 0
			BEGIN
			SET @tempID = (SELECT TOP 1 Id FROM @tblTempWGCityFlightInfo_toLoop)
			SET @geoRefId = (SELECT TOP 1 GeoRefID FROM @tblTempWGCityFlightInfo_toLoop)

			print @tempID
			--Get Data to @tempWGText for further processing

			INSERT INTO @tempWGText(Text_Description)
			SELECT * FROM string_split((SELECT TOP 1 DescriptionInLang FROM @tblTempWGCityFlightInfo_toLoop),'|')
			DELETE @tempWGText WHERE Text_Description = ''

			--Get Data to @temptextLang for further processing
			INSERT INTO @temptextLang(Lang)
			SELECT * FROM string_split((SELECT TOP 1 Language FROM @tblTempWGCityFlightInfo_toLoop),'|')
			DELETE @temptextLang WHERE Lang = ''
		


			SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
			SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
			SET @tempImageID = 1 + @MaxImageID
			SET @tempImagName = (SELECT TOP 1 ImageFileName FROM @tblTempWGCityFlightInfo_toLoop);	
			SET @tempTextID = 1 + @MaxTextID

			--Insert tblWGImage Table and and its Maping Table
			DECLARE @WGFlightImageId INT;
			INSERT INTO dbo.tblWGImage(ImageID,FileName)
			VALUES(@tempImageID,@tempImagName);
			SET @WGFlightImageId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGImage', @WGFlightImageId  

			--Insert tblWGtext Table and and its Maping Table
			DECLARE @WGWGFlightTextId INT;
			INSERT INTO dbo.tblWGtext(TextID)
			VALUES(@tempTextID);
			--Loop through tempWGText and fill dbo.tblWGtext desciption for all the languages
			DECLARE @tempID3 INT;
			WHILE(SELECT COUNT(*) FROM @tempWGText) > 0
				BEGIN				
					SET @tempID3 = (SELECT TOP 1 ID FROM @tempWGText)
					SET @tempLang = (SELECT TOP 1 Lang FROM @temptextLang)
						
	
					IF @tempLang = 'en' 
					BEGIN 
						SET @temptextName = (SELECT TOP 1 Text_Description FROM @tempWGText)	
						UPDATE dbo.tblWGtext SET Text_EN = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'de'
					BEGIN 
						UPDATE dbo.tblWGtext SET Text_DE = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'es'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_ES = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'fr'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_FR = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'it'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_IT = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'zh'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_ZH = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'zh-tw'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_HK = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'ja'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_JA = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'ko'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_KO = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'pt'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_PT = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'ru'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_RU = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'tr'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_TR = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'ar'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_AR = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					DELETE @temptextLang WHERE lang = @tempLang
					DELETE @tempWGText WHERE ID = @tempID3
				END
			SET @WGWGFlightTextId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGWGFlightTextId  

			--Insert tblWGContent Table and and its Maping Table
			DECLARE @WGWGFlightContentId INT;
			INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
			VALUES(@geoRefId,1,@tempImageID,@tempTextID);
			SET @WGWGFlightContentId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGWGFlightContentId  

			DELETE @tblTempWGCityFlightInfo_toLoop WHERE Id = @tempID	
		END			
	DELETE tblTempWGDetailedFlightInfo
	DELETE tblTempWGCityFlightInfo

	--Update tblConfigurationHistory with the content
	DECLARE @comment NVARCHAR(MAX)
	SET @comment = ('Imported new world guide cities data for ' + (SELECT CT.Name FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
					WHERE C.ConfigurationID = @configid) + ' configuration version V' + CONVERT(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					WHERE C.ConfigurationID = @configid)))

	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id IN (SELECT StartedByUserID FROM tblTasks WHERE Id = @currentTaskID) );

	IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'world guide cities' AND ConfigurationID = @configid)
	BEGIN
		UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@currentTaskID), CommentAddedBy = @userName
		WHERE ContentType = 'world guide cities' AND ConfigurationID = @configid
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
		VALUES(@configid,'world guide cities',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID),@comment)
	END
	END
END