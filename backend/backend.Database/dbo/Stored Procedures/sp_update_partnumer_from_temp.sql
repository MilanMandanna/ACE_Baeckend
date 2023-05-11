DROP PROC IF EXISTS sp_update_partnumer_from_temp;
GO
CREATE PROC sp_update_partnumer_from_temp
@aircraftId UNIQUEIDENTIFIER
AS
BEGIN

DECLARE @aricraftDefinitionId INT=0,@tailNumber NVARCHAR(100)
SELECT @aricraftDefinitionId=ISNULL(AD.ConfigurationDefinitionID,0),@tailNumber=AC.TailNumber FROM dbo.tblConfigurationDefinitions CD 
		INNER JOIN tblAircraftConfigurationMapping AD ON AD.ConfigurationDefinitionID=CD.ConfigurationDefinitionID
		INNER JOIN Aircraft AC ON AD.AircraftID=AC.Id WHERE AC.Id=@aircraftId

		IF @aricraftDefinitionId!=0
		BEGIN
		INSERT INTO tblConfigurationDefinitionPartNumber (ConfigurationDefinitionID, PartNumberID,Value) 
		SELECT @aricraftDefinitionId,PartnumberId,Value FROM tblTempAircraftPartnumber WHERE TailNumber=@tailNumber
		END

		DELETE FROM tblTempAircraftPartnumber WHERE TailNumber=@tailNumber;

END
