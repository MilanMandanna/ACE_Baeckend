
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda Chindamada Aiyappa
-- Create date: 08/18/2022
-- Description:	Get the default part number
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_PartNumber] 5080,1,'ABBB'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_PartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_PartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_PartNumber]
    @ConfigurationDefinitionId int ,
	@partNumberCollectionId int,
	@tailNumber NVARCHAR(MAX)
	
    
AS
BEGIN
	
	DECLARE @partnumbertable TABLE (PartNumberID INT, Name NVARCHAR(250), PartNumberCollectionID INT, Description NVARCHAR(500), DefaultPartNumber NVARCHAR(500))

	DECLARE @aricraftDefinitionId INT=0;

	IF LEN(@tailNumber)>0
	BEGIN
		SELECT @aricraftDefinitionId=ISNULL(AD.ConfigurationDefinitionID,0) FROM dbo.tblConfigurationDefinitions CD 
		INNER JOIN tblAircraftConfigurationMapping AD ON AD.ConfigurationDefinitionID=CD.ConfigurationDefinitionID
		INNER JOIN Aircraft AC ON AD.AircraftID=AC.Id WHERE AC.TailNumber=@tailNumber
	
		IF @aricraftDefinitionId!=0
			SET @ConfigurationDefinitionId=@aricraftDefinitionId
    END

	INSERT INTO @partnumbertable 
	SELECT tp.PartNumberID, tp.Name, tp.PartNumberCollectionID, tp.Description, tc.Value  FROM tblConfigurationDefinitionPartNumber tc 
    INNER JOIN tblPartNumber tp ON  tc.PartNumberID =tp.PartNumberID
	INNER JOIN tblOutputTypes ot ON ot.PartNumberCollectionID =tp.PartNumberCollectionID    where tc.ConfigurationDefinitionID = @ConfigurationDefinitionId AND tp.PartNumberCollectionID = @partNumberCollectionId

	INSERT INTO @partnumbertable 
	
	SELECT pa.PartNumberID, pa.Name ,pa.PartNumberCollectionID,pa.Description,pa.DefaultPartNumber from tblPartNumber pa
	INNER JOIN tblOutputTypes ot ON pa.PartNumberCollectionID = ot.PartNumberCollectionID 
	LEFT JOIN  tblConfigurationDefinitions c on c.OutputTypeID =ot.OutputTypeID
	WHERE c.ConfigurationDefinitionID =  @ConfigurationDefinitionId AND pa.PartNumberID NOT IN
	(SELECT tp.PartNumberID FROM tblConfigurationDefinitionPartNumber tc  INNER JOIN tblPartNumber tp ON  tc.PartNumberID = tp.PartNumberID 
	WHERE tc.ConfigurationDefinitionID = @ConfigurationDefinitionId AND tp.PartNumberCollectionID =@partNumberCollectionId)


	SELECT PartNumberID,PartNumberCollectionID,Description,Name,REPLACE(DefaultPartNumber,'%','0') AS DefaultPartNumber FROM @partnumbertable ORDER BY PartNumberID ASC

END
GO