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
				INSERT INTO [dbo].[tblConfigurationComponents] (Path,ConfigurationComponentTypeID,Name)
				VALUES
				( @ConfigCompPath, @ConfigCompTypeID ,@ConfigCompName);
			COMMIT
		END TRY
		BEGIN CATCH
			INSERT INTO @retTable(message) VALUES ('Failure')
		END CATCH
	END	
END

GO