SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Mohan
-- Create date: 05/17/2022
-- Description:	checks if an update is available
-- Sample EXEC [dbo].[SP_GetUpdatesAvailable] 1,1
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetUpdatesAvailable]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetUpdatesAvailable]
END
GO

CREATE PROCEDURE [dbo].[SP_GetUpdatesAvailable]
	@configurationDefinitionID INT,
	@configurationId INT
AS
BEGIN
	DECLARE @version INT
	DECLARE @returnTable TABLE(updatesAvailable BIT, updateType NVARCHAR(250))

	DECLARE @parentVersion INT
	DECLARE @ChildVersion INT,@parentDefId INT,@parentConfigurationId INT

	SELECT @parentDefId=ConfigurationDefinitionParentID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID=@configurationDefinitionID AND ConfigurationDefinitionParentID>0 AND ConfigurationDefinitionParentID!=ConfigurationDefinitionID

	SELECT @parentConfigurationId = MAX(ConfigurationID) FROM tblconfigurations WHERE ConfigurationDefinitionID = @parentDefId AND Locked = 1

	SELECT @parentVersion=(CASE WHEN MAX(C.version)>ISNULL(CD.UpdatedUpToVersion, 0) THEN MAX(version) ELSE ISNULL(CD.UpdatedUpToVersion, 0) END) 
	FROM tblConfigurations C INNER JOIN tblConfigurationDefinitions CD ON c.ConfigurationDefinitionID=cd.ConfigurationDefinitionID
	WHERE cd.ConfigurationDefinitionID=@parentDefId AND c.Locked=1 GROUP BY c.ConfigurationDefinitionID,CD.UpdatedUpToVersion

	SELECT @ChildVersion= ISNULL(CD.UpdatedUpToVersion, 0)  
	FROM tblConfigurations C INNER JOIN tblConfigurationDefinitions CD ON c.ConfigurationDefinitionID=cd.ConfigurationDefinitionID
	WHERE cd.ConfigurationDefinitionID=@configurationDefinitionID AND c.Locked=1 GROUP BY c.ConfigurationDefinitionID,CD.UpdatedUpToVersion

	DECLARE @mergeDate DATETIME
	IF @parentVersion > @ChildVersion --Either Updates Available or Pending
	BEGIN
		--Either PopulateMergeDetails or Perform Data Merge is in progress
		IF EXISTS (SELECT 1 FROM tblTasks WHERE configurationId = @configurationId AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name in('UI Merge Configuration','PerformDataMerge'))
		AND TaskStatusID IN (1,2)) 
		BEGIN
			INSERT INTO @returnTable VALUES(1, 'Updates Pending')
		END
		--Once PopulateMergeDetails is completed, Check Perform Data Merge status based on PopulateMergeDetails date and parent configurationId
		ELSE IF EXISTS (SELECT 1 FROM tblTasks WHERE ConfigurationID = @configurationId AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = 'UI Merge Configuration') AND TaskStatusID = 4 AND TaskDataJSON LIKE '%' + CAST(@parentConfigurationId AS NVARCHAR) + '%')
		BEGIN
			SET @mergeDate = (SELECT TOP 1 DateStarted FROM tblTasks WHERE ConfigurationID = @configurationId AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = 'UI Merge Configuration') AND TaskStatusID = 4
									AND TaskDataJSON LIKE '%' + CAST(@parentConfigurationId AS NVARCHAR) + '%' ORDER BY DateLastUpdated DESC)
			--Either Perform Data Merge is in progress or not initiated 
			IF NOT EXISTS (SELECT 1 FROM tblTasks WHERE ConfigurationID = @configurationId AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = 'PerformDataMerge') AND DateStarted > @mergeDate AND TaskStatusID = 4)
			BEGIN
				INSERT INTO @returnTable VALUES(1, 'Updates Pending')
			END
			--Perform Data Merge also got completed
			ELSE
			BEGIN
				INSERT INTO @returnTable VALUES(1, 'Updates Available')
			END
		END
		--Populate Merge Details task itself not initiated
		ELSE
		BEGIN
			INSERT INTO @returnTable VALUES(1, 'Updates Available')
		END
	END
	--No Updates Available
	ELSE
	BEGIN
		INSERT INTO @returnTable VALUES(0, 'Updates Available')
	END
    SELECT * FROM @returnTable
	END
GO