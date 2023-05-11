SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and update the xml data for the Flightinfo
-- Sample EXEC [dbo].[SP_FlightInfo_MoveFlightInfoLocation] 18, 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_MoveFlightInfoLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_MoveFlightInfoLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_MoveFlightInfoLocation]
@configurationId INT,
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT InfoItems FROM cust.config_tblWebmain(@configurationId) as WM
	END
	ELSE IF (@type = 'update' AND @xmlData IS NOT NULL)
	BEGIN
		BEGIN TRY
			declare @mappedWebMainID int	
			declare @updateKey int
			set @mappedWebMainID = (select WebMainID from cust.tblWebMainMap where configurationId = @configurationId)
			if not @mappedWebMainID is null
       		BEGIN	
			   
			   	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebmain', @mappedWebMainID, @updateKey out
				UPDATE WM
				SET InfoItems = @xmlData FROM cust.config_tblWebmain(@configurationId) as WM WHERE WM.WebMainID = @updateKey
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