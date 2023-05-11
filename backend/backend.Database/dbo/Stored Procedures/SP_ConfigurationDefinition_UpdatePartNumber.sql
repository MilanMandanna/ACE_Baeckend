SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda Chindamada Aiyappa
-- Create date: 08/18/2022
-- Description:	Update the partnumber based on given collection
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_UpdatePartNumber] 5080,1,'072-4599-788888','ABBB'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_UpdatePartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_UpdatePartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_UpdatePartNumber]
    @ConfigurationDefinitionID int, 
	@PartNumberID int, 
	@Value varchar(255),
	@TailNumber NVARCHAR(255)
	
    
AS
BEGIN
	DECLARE @AircraftConfigurationDefinitionID INT;
	SET @AircraftConfigurationDefinitionID =(select ISNULL(ConfigurationDefinitionID,0) from tblAircraftConfigurationMapping ac inner join Aircraft a on ac.AircraftID = a.ID where a.TailNumber =@TailNumber)
	IF @AircraftConfigurationDefinitionID IS NULL
		BEGIN
			IF NOT EXISTS ( SELECT 1 FROM tblTempAircraftPartnumber WHERE PartNumberID = @PartNumberID AND ProductConfigurationDefinitionId= @ConfigurationDefinitionID)
			     INSERT INTO tblTempAircraftPartnumber(ProductConfigurationDefinitionId,TailNumber,PartnumberId,Value) VALUES(@ConfigurationDefinitionID,@TailNumber,@PartNumberID,@Value)
				 ELSE
				 UPDATE tblTempAircraftPartnumber SET Value = @Value WHERE  ProductConfigurationDefinitionId = @ConfigurationDefinitionID and  PartNumberID= @PartNumberID 
		END
	ELSE 
		BEGIN
		IF NOT EXISTS ( SELECT 1 FROM tblConfigurationDefinitionPartNumber WHERE ConfigurationDefinitionID = @AircraftConfigurationDefinitionID  AND PartNumberID = @PartNumberID)
			INSERT INTO tblConfigurationDefinitionPartNumber (ConfigurationDefinitionID, PartNumberID,Value) VALUES (@AircraftConfigurationDefinitionID,@PartNumberID, @Value)
			ELSE
			UPDATE tblConfigurationDefinitionPartNumber SET Value = @Value WHERE  ConfigurationDefinitionID = @AircraftConfigurationDefinitionID and  PartNumberID= @PartNumberID 
		END
	
END
GO