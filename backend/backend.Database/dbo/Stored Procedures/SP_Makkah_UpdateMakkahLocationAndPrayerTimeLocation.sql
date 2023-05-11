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
	DECLARE @mappedMakkahId INT, @mappedRLIID INT, @updateKey INT, @currentXML XML, @RliId INT, @makkahID INT
	SET @mappedRLIID = (SELECT RLIID from cust.tblRLIMap WHERE configurationId = @configurationId)
	SET @mappedMakkahId = (SELECT MakkahID from cust.tblMakkahMap WHERE configurationId = @configurationId)

	IF (@type = 'available')
	BEGIN
		IF NOT @mappedRLIID IS NULL
       	BEGIN	
			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblRLI', @mappedRLIID, @updateKey OUT
			IF EXISTS (SELECT R.Rli	FROM cust.config_tblRLI(@ConfigurationId) AS R WHERE R.Rli.exist('/rli/mecca_rli/text()') = 1 AND R.RLIID = @updateKey)
			BEGIN
				UPDATE R 
				SET Rli.modify('replace value of (/rli/mecca_rli/text())[1] with sql:variable("@data")') 
				FROM cust.config_tblRLI(@ConfigurationId) AS R WHERE R.RLIID = @updateKey
			END
			ELSE
			BEGIN
				SET @currentXML = ('<mecca_rli>'+ @data +'</mecca_rli>')
				UPDATE R 
				SET Rli.modify('insert sql:variable("@currentXML") into (/rli[1])') 
				FROM cust.config_tblRLI(@ConfigurationId) AS R WHERE R.RLIID = @updateKey    	
			END
		END	
		ELSE
		BEGIN
			SET @currentXML = ('<rli><mecca_rli>'+ @data +'</mecca_rli></rli>')

			INSERT INTO cust.tblRli(Rli) VALUES (@currentXML)
			SET @RliId = (SELECT MAX(RLIID) FROM cust.tblRli)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblRli', @RliId
		END
	END
	ELSE IF (@type = 'prayertime')
	BEGIN
		IF NOT @mappedMakkahId IS NULL
       	BEGIN	

			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMakkah', @mappedMakkahId, @updateKey OUT
			IF EXISTS (SELECT M.Makkah FROM cust.config_tblMakkah(@configurationId) AS M WHERE M.Makkah.exist('/makkah/default_calculation_city/text()') = 1 AND M.MakkahId = @updateKey)
			BEGIN
				UPDATE M 
				SET Makkah.modify('replace value of (/makkah/default_calculation_city/text())[1] with sql:variable("@data")') 
				FROM cust.config_tblMakkah(@configurationId) AS M WHERE M.MakkahId = @updateKey
			END
			ELSE
			BEGIN
				SET @currentXML = ('<default_calculation_city>'+ @data +'</default_calculation_city>')
				UPDATE M 
				SET Makkah.modify('insert sql:variable("@currentXML") into (/makkah[1])') 
				FROM cust.config_tblMakkah(@ConfigurationId) AS M WHERE M.MakkahId = @updateKey    	
			END
		END
		ELSE
		BEGIN
			SET @currentXML = ('<makkah><default_calculation_city>'+ @data +'</default_calculation_city></makkah>')

			INSERT INTO cust.tblMakkah (Makkah) VALUES (@currentXML)
			SET @makkahID = (SELECT MAX(MakkahID) FROM cust.tblMakkah)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblMakkah', @makkahID
		END
	END
	ELSE IF (@type = 'calculation')
	BEGIN
		IF NOT @mappedMakkahId IS NULL
       	BEGIN	
		   	EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMakkah', @mappedMakkahId, @updateKey OUT
			IF EXISTS (SELECT M.Makkah FROM cust.config_tblMakkah(@configurationId) AS M WHERE M.Makkah.exist('/makkah/prayer_time_calculation/text()') = 1 AND M.MakkahId = @updateKey)
			BEGIN
				UPDATE M 
				SET Makkah.modify('replace value of (/makkah/prayer_time_calculation/text())[1] with sql:variable("@data")') 
				FROM cust.config_tblMakkah(@configurationId) AS M WHERE M.MakkahId = @updateKey
			END
			ELSE
			BEGIN
				SET @currentXML = ('<prayer_time_calculation>'+ @data +'</prayer_time_calculation>')
				UPDATE M 
				SET Makkah.modify('insert sql:variable("@currentXML") into (/makkah[1])') 
				FROM cust.config_tblMakkah(@ConfigurationId) AS M WHERE M.MakkahId = @updateKey    	
			END
		END
		ELSE
		BEGIN
			SET @currentXML = ('<makkah><prayer_time_calculation>'+ @data +'</prayer_time_calculation></makkah>')

			INSERT INTO cust.tblMakkah (Makkah) VALUES (@currentXML)
			SET @makkahID = (SELECT MAX(MakkahID) FROM cust.tblMakkah)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblMakkah', @makkahID
		END
	END
END
GO