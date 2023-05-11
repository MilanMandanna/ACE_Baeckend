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
-- Sample EXEC [dbo].[SP_CityPopulation_Import] 105, '4DBED025-B15F-4760-B925-34076D13A10A' , '23e75fe0-d2dd-4098-8a6e-e10588b2fed2'
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
	DECLARE @userName NVARCHAR(50),@LatestConfigHistoryID NVARCHAR(50);
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
	DECLARE @comment NVARCHAR(MAX)
	SET @comment = ('Imported new population data for ' + (SELECT CT.Name FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
				WHERE C.ConfigurationID = @configid) + ' configuration version V' + CONVERT(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				WHERE C.ConfigurationID = @configid)))

	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id IN (SELECT StartedByUserID FROM tblTasks WHERE Id = @currentTaskID) );

	IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'populations' AND ConfigurationID = @configid)
	BEGIN
		UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@currentTaskID), CommentAddedBy = @userName
		WHERE ContentType = 'populations' AND ConfigurationID = @configid
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
		VALUES(@configid,'populations',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID),@comment)
	END
END
GO
