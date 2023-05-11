SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get Makkah prayer times
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahPrayerTimes] 105
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
	DECLARE @xmlValue NVARCHAR(500), @featuresetdisplayvalue NVARCHAR(MAX), @featuresetvalue NVARCHAR(MAX), @typeName NVARCHAR(500), @displayName NVARCHAR(MAX),
			@typeId INT, @displayID INT, @typefeatureset INT, @displayfeatureset INT

	SET @xmlValue = (SELECT MN.V.value('(text())[1]', 'nvarchar(max)')
			FROM cust.config_tblMakkah(@ConfigurationId) as M
			OUTER APPLY M.Makkah.nodes('makkah/prayer_time_calculation') AS MN(V))

	SET @featuresetvalue = (SELECT FS.Value FROM tblFeatureSet FS
			INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
			INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
			WHERE FS.Name = 'MakkahCalculation-TypesList' AND C.ConfigurationID = @ConfigurationId)

	SET @typefeatureset = (SELECT FS.FeatureSetID FROM tblFeatureSet FS
			INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
			INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
			WHERE FS.Name = 'MakkahCalculation-TypesList' AND C.ConfigurationID = @ConfigurationId)

	SET @featuresetdisplayvalue = (SELECT FS.Value FROM tblFeatureSet FS
			INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
			INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
			WHERE FS.Name = 'MakkahCalculation-TypesDisplayList' AND C.ConfigurationID = @ConfigurationId)

	SET @displayfeatureset = (SELECT FS.FeatureSetID FROM tblFeatureSet FS
			INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
			INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
			WHERE FS.Name = 'MakkahCalculation-TypesList' AND C.ConfigurationID = @ConfigurationId)

	DECLARE @tmpnametable TABLE(id INT IDENTITY(1,1), featureSetId INT, name NVARCHAR(500))
	DECLARE @tmpdisplaynametable TABLE(id INT IDENTITY(1,1), featureSetId INT, name NVARCHAR(500))
	DECLARE @outputTable TABLE(id INT IDENTITY(1,1), MakkahTypeName NVARCHAR(MAX), MakkahDisplayName NVARCHAR(MAX))

	INSERT INTO @tmpnametable (featureSetId, name) SELECT @typefeatureset, * FROM STRING_SPLIT(@featuresetvalue,',')

	INSERT INTO @tmpdisplaynametable (featureSetId, name) SELECT @displayfeatureset,* FROM STRING_SPLIT(@featuresetdisplayvalue,';')

	IF (@xmlValue IS NOT NULL)
	BEGIN
	INSERT INTO @outputTable(MakkahTypeName, MakkahDisplayName) SELECT A.name, B.name FROM @tmpnametable A
		LEFT JOIN @tmpdisplaynametable B ON a.featuresetid = B.featuresetid
		WHERE B.name LIKE '%' +  A.name + '%' AND A.name NOT IN (@xmlValue)
	END
	ELSE
	BEGIN
		INSERT INTO @outputTable(MakkahTypeName, MakkahDisplayName) SELECT A.name, B.name FROM @tmpnametable A
		LEFT JOIN @tmpdisplaynametable B ON a.featuresetid = B.featuresetid
		WHERE B.name LIKE '%' +  A.name + '%'
	END

	SELECT MakkahTypeName, MakkahDisplayName FROM @outputTable
END
GO