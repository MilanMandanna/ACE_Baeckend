SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new compass airplanes
-- Sample EXEC [dbo].[SP_Compass_GetAvailableAircraftAndLocation] 223, 'aircraft'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetAvailableAircraftAndLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetAvailableAircraftAndLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetAvailableAircraftAndLocation]  
@configurationId INT,  
@type NVARCHAR(150)  
AS  
BEGIN  
 DECLARE @inputstring NVARCHAR(1000), @location NVARCHAR(500), @geoRefId NVARCHAR(500)
 DECLARE @tempTable TABLE (name NVARCHAR(500), georefID NVARCHAR(500))
 IF (@type = 'location')  
  BEGIN
	IF EXISTS(SELECT R.RLI
			FROM cust.config_tblRLI(@configurationId) as R
			WHERE R.RLI.exist('/rli/location1') = 1)
	BEGIN
		SET @location = (SELECT rli.value('(rli/location1/@name)[1]', 'varchar(max)')
					FROM cust.config_tblRLI(@configurationId) as R)

		SET @geoRefId = (SELECT rli.value('(rli/location1)[1]', 'varchar(max)')
				FROM cust.config_tblRLI(@configurationId) as R)

		INSERT INTO @tempTable VALUES (@location, @geoRefId)
	END
	ELSE
	BEGIN
		INSERT INTO @tempTable VALUES ('Closest Location', -3)
	END

	IF EXISTS(SELECT R.RLI FROM cust.config_tblRLI(@configurationId) as R

			WHERE R.RLI.exist('/rli/location2') = 1)
	BEGIN
		SET @location = (SELECT rli.value('(rli/location2/@name)[1]', 'varchar(max)')
						FROM cust.config_tblRLI(@configurationId) as R)

		SET @geoRefId = (SELECT rli.value('(rli/location2)[1]', 'varchar(max)') 				
				FROM cust.config_tblRLI(@configurationId) as R)

			INSERT INTO @tempTable VALUES (@location, @geoRefId)
	END
	ELSE
	BEGIN
		INSERT INTO @tempTable VALUES ('Closest Location', -3)
	END
	SELECT * FROM @tempTable
  END  
 ELSE IF (@type = 'aircraft')  
  BEGIN  
    SET @inputstring =(SELECT (rli.value('(rli/airplanes)[1]', 'varchar(max)')) AS Airplanes  
  						FROM cust.config_tblRLI(@configurationId) as R)  

    SELECT ty.Name,ty.[AeroPlaneTypeID] FROM  [dbo].[tblRliAeroPlaneTypes] ty INNER JOIN [dbo].[tblRliAeroPlaneTypesMap]
				tyMap on ty.[AeroPlaneTypeID] = tyMap.[AeroPlaneTypeID] WHERE [ConfigurationID]=@configurationId AND ty.Name IN (SELECT * FROM STRING_SPLIT(@inputstring, ','))
  END  
 ELSE IF (@type = 'available')  
  BEGIN  

	SET @inputstring =(SELECT (rli.value('(rli/airplanes)[1]', 'varchar(max)')) AS Airplanes  
  	FROM cust.config_tblRLI(@configurationId) as R)  


	SELECT ty.Name,ty.[AeroPlaneTypeID] FROM  [dbo].[tblRliAeroPlaneTypes] ty INNER JOIN [dbo].[tblRliAeroPlaneTypesMap]
				tyMap on ty.[AeroPlaneTypeID] = tyMap.[AeroPlaneTypeID] WHERE [ConfigurationID]=@configurationId 
				AND ty.Name NOT IN (SELECT * FROM STRING_SPLIT(@inputstring, ','))

  END  
END  