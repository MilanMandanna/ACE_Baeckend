SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and update the xml data for the Worldclock
-- Sample EXEC [dbo].[SP_WorldClock_MoveWorldclockLocation] 18, 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_MoveWorldclockLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_MoveWorldclockLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_MoveWorldclockLocation]
@configurationId INT,
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT WC.WorldClockCities AS xmlData 
        FROM cust.config_tblWorldClockCities(@configurationId) as WC
	END
	ELSE IF (@type = 'update' AND @xmlData IS NOT NULL)
	BEGIN
		BEGIN TRY
			declare @mappedWorldClockCityID int	
        	declare @updateKey int

        	set @mappedWorldClockCityID = (select WorldClockCityID from cust.tblWorldClockCitiesMap where configurationId = @configurationId)
        	if not @mappedWorldClockCityID is null
       		 BEGIN
		    	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldTimeZonePlaceNames', @mappedWorldClockCityID, @updateKey out
				UPDATE WC
				SET WorldClockCities = @xmlData FROM cust.config_tblWorldClockCities(@configurationId) as WC WHERE WC.WorldClockCityID = @updateKey
			END
			SELECT 1 AS retValue
		END TRY
		BEGIN CATCH
			SELECT 0 AS retValue
		END CATCH
	END
	ELSE
	BEGIN
		SELECT 0 AS retValue
	END
END
GO