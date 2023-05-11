SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Procedure to retrieve all Makkah page loading data
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahData] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_GetMakkahData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_GetMakkahData]
END
GO  

CREATE PROCEDURE [dbo].[SP_Makkah_GetMakkahData]  
@ConfigurationId INT   
AS  
BEGIN  
	 DECLARE @tempTable TABLE(Details NVARCHAR(500))  
	 DECLARE @tempDisplayTable Table (Id INT IDENTITY, displayName NVARCHAR(150), displayValue NVARCHAR(150))  
	 DECLARE @geoRefTable TABLE(Id INT IDENTITY, GeoRefId INT)  
	 DECLARE @geoRefId NVARCHAR(100), @location NVARCHAR(250), @xml XML  
  
  
	 --- Region to insert Makkah locations  
  
	 SET @geoRefId = (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)')  
	  FROM cust.config_tblRLI(@configurationId) as R  
	 OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V))  
  
	 IF (@geoRefId IS NOT NULL)  
	 BEGIN  
	  IF(@geoRefId = '-10')  
	  BEGIN  
	   SET @location = 'Disabled'  
	  END  
	  ELSE IF(@geoRefId = '-1')  
	  BEGIN  
	   SET @location = 'Departure'  
	  END  
	  ELSE IF(@geoRefId = '-2')  
	  BEGIN  
	   SET @location = 'Destination'  
	  END  
	  ELSE IF(@geoRefId = '-3')  
	  BEGIN  
	   SET @location = 'Closest Location'  
	  END  
	  ELSE IF(@geoRefId = '-4')  
	  BEGIN  
	   SET @location = 'Current Location'  
	  END  
	  ELSE  
	  BEGIN  
	   SET @location = (SELECT GR.Description FROM dbo.config_tblGeoRef(@ConfigurationId) as GR WHERE GR.isMakkahPoi = 1 AND GR.GeoRefId = @geoRefId)  
	  END  
  
	  INSERT INTO @tempTable VALUES(@geoRefId + ',' + @location)  
	 END  
	 ELSE  
	 BEGIN  
	  INSERT INTO @tempTable VALUES('-3, Closest Location')  
	 END  
  
	 -- Region to get prayertime values  
	 SET @geoRefId = (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId  
	 FROM cust.config_tblMakkah(@configurationId) as M 
	 OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V))  
  
	 IF (@geoRefId IS NOT NULL)  
	 BEGIN  
	  IF(@geoRefId = '-1')  
	  BEGIN  
	   SET @location = 'Departure'  
	  END  
	  ELSE IF(@geoRefId = '-2')  
	  BEGIN  
	   SET @location = 'Destination'  
	  END  
	  ELSE IF(@geoRefId = '-3')  
	  BEGIN  
	   SET @location = 'Closest Location'  
	  END  
	  ELSE IF(@geoRefId = '-4')  
	  BEGIN  
	   SET @location = 'Current Location'  
	  END  
	  ELSE  
	  BEGIN  
	   SET @location = (SELECT GR.Description FROM dbo.config_tblGeoRef(@ConfigurationId) as GR WHERE GR.isMakkahPoi = 1 AND GR.GeoRefId = @geoRefId)  
	  END  
  
	  INSERT INTO @tempTable VALUES(@geoRefId + ',' + @location)  
	 END  
	 ELSE  
	 BEGIN  
	  INSERT INTO @tempTable VALUES('-3, Closest Location')  
	 END  
  
	 -- Region to select Makkah values  
	 SET @location = ISNULL((SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId  
	 FROM cust.config_tblMakkah(@configurationId) as M
	 OUTER APPLY M.Makkah.nodes('makkah/prayer_time_calculation') AS RLN(V)), '')
  
	 INSERT INTO @tempTable VALUES (@location)  
  
	 -- Region to get values for mecca display  
	 SET @xml = (SELECT Rli FROM cust.config_tblRLI(@configurationId) as R  )  
  
	 INSERT INTO @tempDisplayTable SELECT   
	 b.value('local-name(.)','varchar(50)') AS columnname,  
	 b.value('.','VARCHAR(MAX)') AS Valuename  
	 FROM @xml.nodes('/rli/mecca_display') p(k)  
	 CROSS APPLY k.nodes('@*') a(b) 
	 ORDER BY columnname ASC
  
	 WHILE (SELECT Count(*) FROM @tempDisplayTable) > 0  
	 BEGIN  
	  SET @location = (SELECT TOP 1 displayValue FROM @tempDisplayTable)  
  
	  INSERT INTO @tempTable VALUES(@location)  
  
	  DELETE TOP (1) FROM @tempDisplayTable  
	 END  
  
	 SELECT * FROM @tempTable  
END  