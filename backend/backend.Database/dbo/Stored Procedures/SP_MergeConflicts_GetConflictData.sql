/****** Object:  StoredProcedure [dbo].[SP_MergeConflicts_GetConflictData]    Script Date: 10/25/2022 11:03:23 AM ******/
IF OBJECT_ID('[dbo].[SP_MergeConflicts_GetConflictData]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_MergeConflicts_GetConflictData]
END
GO
/****** Object:  StoredProcedure [dbo].[SP_MergeConflicts_GetConflictData]    Script Date: 10/25/2022 11:03:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_MergeConflicts_GetConflictData]
	@taskID UNIQUEIDENTIFIER = NULL
AS
BEGIN
	DROP TABLE IF EXISTS #TEMP_RESULT
	CREATE TABLE #TEMP_RESULT (ID INT, ContentID INT, ContentType NVARCHAR(max), Description NVARCHAR(max),DisplayName NVARCHAR(MAX), ParentValue NVARCHAR(MAX), ChildValue NVARCHAR(MAX),SelectedValue NVARCHAR(MAX))
	INSERT INTO #TEMP_RESULT
	EXEC SP_getCountryConflicts @taskID
	INSERT INTO #TEMP_RESULT
	EXEC SP_getPlaceNameConflicts @taskID
	INSERT INTO #TEMP_RESULT
	EXEC SP_getRegionConflicts @taskID
	INSERT INTO #TEMP_RESULT
	EXEC SP_getAirportConflicts @taskID
	SELECT * FROM #TEMP_RESULT ORDER BY ID
END