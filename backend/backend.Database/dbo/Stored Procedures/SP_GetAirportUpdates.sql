/****** Object:  StoredProcedure [dbo].[SP_GetAirportUpdates]    Script Date: 11/02/2022 5:15:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetAirportUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetAirportUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetAirportUpdates]    Script Date: 11/02/2022 5:15:06 PM ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROC [dbo].[SP_GetAirportUpdates]
	@tableXml XML
AS
BEGIN

	DROP TABLE IF EXISTS #TEMP_AIRPORT_PARENT
	DROP TABLE IF EXISTS #TEMP_AIRPORT_CHILD
    DROP TABLE IF EXISTS #TEMP

	CREATE TABLE #TEMP_AIRPORT_PARENT(ID INT, AirportId int,GeoRefId int,Description varchar(MAX),FourLetID NVARCHAR(8),ThreeLetID NVARCHAR(6),Lat decimal(9),Lon decimal(9),City NVARCHAR(MAX), Action NVARCHAR(10));
	CREATE TABLE #TEMP_AIRPORT_CHILD(ID INT, AirportId int,GeoRefId int,Description varchar(MAX),FourLetID NVARCHAR(8),ThreeLetID NVARCHAR(6),Lat decimal(9),Lon decimal(9),City NVARCHAR(MAX), Action NVARCHAR(10));
 
	CREATE TABLE #TEMP (ID INT IDENTITY, TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(10))
	INSERT INTO #TEMP 
	SELECT Tbl.Col.value('@TableName', 'NVARCHAR(100)') AS TableName,  Tbl.Col.value('@CurrentKey', 'INT') AS CurrentKey,  
       Tbl.Col.value('@PreviousKey', 'INT') AS PreviousKey, Tbl.Col.value('@Action', 'NVARCHAR(10)') AS Action 
	FROM   @tableXml.nodes('//row') Tbl(Col) WHERE Tbl.Col.value('@TableName', 'NVARCHAR(100)') IN('tblAirportInfo');
  
	DECLARE @ID INT, @TableName VARCHAR(50),@ParentKey INT,@ChildKey INT, @Action NVARCHAR(10)

	DECLARE cur_tbl CURSOR 
	FOR
	SELECT ID,TableName,PreviousKey,CurrentKey,Action
	FROM   #TEMP WHERE Action = 'Update'
	
	OPEN cur_tbl
	FETCH next FROM cur_tbl INTO @ID,@TableName ,@ParentKey ,@ChildKey, @Action 
	WHILE @@FETCH_STATUS = 0
	BEGIN
                              
		INSERT INTO #TEMP_AIRPORT_PARENT(ID,AirportId,FourLetID,ThreeLetID,Lat,Lon,City,Description,Action)                                 
		SELECT @ID, airPort.AirportInfoID, airPort.FourLetID,airPort.ThreeLetID,airPort.Lat,airPort.Lon, airPort.CityName, geo.Description,@Action
		FROM tblAirportInfo airPort 
		INNER JOIN tblGeoRef geo on geo.GeoRefId=airPort.GeoRefId 
		WHERE AirportInfoID in(@ParentKey);
 
		INSERT INTO #TEMP_AIRPORT_CHILD(ID,AirportId,FourLetID,ThreeLetID,Lat,Lon,City,Description,Action)                                  
		SELECT @ID, airPort.AirportInfoID,airPort.FourLetID,airPort.ThreeLetID,airPort.Lat,airPort.Lon, airPort.CityName, geo.Description,@Action
		FROM tblAirportInfo airPort 
		INNER JOIN tblGeoRef geo on geo.GeoRefId=airPort.GeoRefId 
		WHERE AirportInfoID in(@ChildKey);
 
		FETCH NEXT FROM cur_tbl INTO @ID, @TableName, @ParentKey, @ChildKey, @Action
	END 
	CLOSE cur_tbl
	DEALLOCATE cur_tbl
	--compare 2 tables and display the values
	--SELECT * FROM #TEMP_AIRPORT_PARENT
	--SELECT * FROM #TEMP_AIRPORT_CHILD
	DECLARE @TEMP_RESULT TABLE(ID INT, [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX), Action NVARCHAR(10))
	INSERT INTO @TEMP_RESULT
	SELECT ID, [key], Parent_Value = MAX( CASE WHEN Src=1 THEN Value END), Child_Value = MAX( CASE WHEN Src=2 THEN Value END), Action
	FROM ( SELECT Src=1, ID, Action, B.*
			 FROM #TEMP_AIRPORT_PARENT A
			 CROSS APPLY (SELECT [Key], Value FROM OPENJSON((SELECT A.ID, ISNULL(A.FourLetID, '') AS FourLetID,ISNULL(A.ThreeLetID, '') AS ThreeLetID,A.Lat,A.Lon,A.City FOR JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES))) 
				   B
			UNION ALL
			SELECT Src=2, ID, Action, B.*
			 FROM #TEMP_AIRPORT_CHILD A
			 CROSS APPLY (SELECT [Key], Value FROM OPENJSON((SELECT A.ID, ISNULL(A.FourLetID, '') AS FourLetID,ISNULL(A.ThreeLetID, '') AS ThreeLetID,A.Lat,A.Lon,A.City FOR JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES))) 
				   B
		  ) A
	GROUP BY ID, [key], Action
	HAVING MAX(CASE WHEN Src=1 THEN Value END) <> MAX(CASE WHEN Src=2 THEN Value END)
	ORDER BY ID, [key]
	--SELECT * FROM @TEMP_RESULT 
 
	SELECT C.AirportId AS ContentID, 'Airport' AS ContentType, c.Description AS Name, t.[Key] AS Field, 
	t.Parent_value AS PreviousValue, t.Child_value AS CurrentValue, t.Action
	FROM @TEMP_RESULT t, #TEMP_AIRPORT_CHILD c WHERE  t.ID = c.ID 
	UNION
	SELECT t.CurrentKey AS ContentID, 'Airport' AS ContentType, g.Description AS Name, NULL, NULL, NULL, t.Action
	FROM #TEMP t, tblAirportInfo a, tblGeoRef g WHERE t.CurrentKey = a.AirportInfoID AND a.GeoRefID = g.GeoRefId AND t.Action IN ('Insert', 'Delete')
END
GO
