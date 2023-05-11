/****** Object:  StoredProcedure [dbo].[SP_getAirportConflicts]    Script Date: 10/27/2022 5:15:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getAirportConflicts]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getAirportConflicts]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getAirportConflicts]    Script Date: 10/27/2022 5:15:06 PM ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROC [dbo].[SP_getAirportConflicts]
@taskId UNIQUEIDENTIFIER
AS
BEGIN

 DROP TABLE IF EXISTS #TEMP_AIRPORT_PARENT
  DROP TABLE IF EXISTS #TEMP_AIRPORT_CHILD
    DROP TABLE IF EXISTS #TEMP

CREATE TABLE #TEMP_AIRPORT_PARENT(ID INT,MergeChoice INT, SelectedKey INT,AirportId int,GeoRefId int,Description varchar(MAX),FourLetID NVARCHAR(8),ThreeLetID NVARCHAR(6),Lat decimal(9),Lon decimal(9),City NVARCHAR(MAX));
CREATE TABLE #TEMP_AIRPORT_CHILD(ID INT,MergeChoice INT, SelectedKey INT,AirportId int,GeoRefId int,Description varchar(MAX),FourLetID NVARCHAR(8),ThreeLetID NVARCHAR(6),Lat decimal(9),Lon decimal(9),City NVARCHAR(MAX));
 
SELECT ID,ChildKey,ParentKey,TableName,SelectedKey,MergeChoice INTO #TEMP FROM tblMergeDetails where MergeChoice NOT IN(1,3) AND TableName IN('tblAirportInfo') AND TaskId = @taskId;
 
DECLARE @TableName varchar(50),@ParentKey INT,@ChildKey INT,@MergeChoice INT,@SelectedKey INT,@ID INT
 
DECLARE cur_tbl CURSOR 
 FOR
              SELECT ID,ChildKey,ParentKey,TableName,MergeChoice,SelectedKey
              FROM   #TEMP
 
                      OPEN cur_tbl
 
            FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                    --print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN
                              
                                 insert into #TEMP_AIRPORT_PARENT(ID,MergeChoice,SelectedKey,AirportId,FourLetID,ThreeLetID,Lat,Lon,City,Description) 
                                 
									SELECT @ID,@MergeChoice,@SelectedKey,airPort.AirportInfoID, airPort.FourLetID,airPort.ThreeLetID,airPort.Lat,airPort.Lon, airPort.CityName, geo.Description
									FROM tblAirportInfo airPort 
                                 INNER JOIN tblGeoRef geo on geo.GeoRefId=airPort.GeoRefId 
                                 WHERE AirportInfoID in(@ParentKey);
 
                                 insert into #TEMP_AIRPORT_CHILD(ID,MergeChoice,SelectedKey,AirportId,FourLetID,ThreeLetID,Lat,Lon,City,Description) 
                                 
									SELECT @ID,@MergeChoice,@SelectedKey,airPort.AirportInfoID,airPort.FourLetID,airPort.ThreeLetID,airPort.Lat,airPort.Lon, airPort.CityName, geo.Description
									FROM tblAirportInfo airPort 
                                 INNER JOIN tblGeoRef geo on geo.GeoRefId=airPort.GeoRefId 
                                 WHERE AirportInfoID in(@ChildKey);
 
                           FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                      END
 CLOSE cur_tbl

            DEALLOCATE cur_tbl
--compare 2 tables and display the values

DECLARE @TEMP_RESULT TABLE(ID INT,  [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX))
INSERT INTO @TEMP_RESULT
Select ID, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end)
From ( Select Src=1, ID, B.*
         From #TEMP_AIRPORT_PARENT A
         Cross Apply (Select [Key], Value From OpenJson((Select A.ID,ISNULL(A.FourLetID, '') AS FourLetID,ISNULL(A.ThreeLetID, '') AS ThreeLetID,A.Lat,A.Lon,A.City For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
               B
        Union All
        Select Src=2, ID, B.*
         From #TEMP_AIRPORT_CHILD A
         Cross Apply (Select [Key], Value From OpenJson((Select A.ID,ISNULL(A.FourLetID, '') AS FourLetID,ISNULL(A.ThreeLetID, '') AS ThreeLetID,A.Lat,A.Lon,A.City For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
               B
      ) A
Group By ID, [key]
Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
Order By ID, [key]
--SELECT * FROM @TEMP_RESULT 
 
SELECT t.ID, C.AirportId AS ContentID, 'Airport' AS ContentType, c.Description AS Description, t.[Key] AS DisplayName, t.Parent_value AS ParentValue, t.Child_value AS ChildValue, 
 CASE WHEN m.SelectedKey = m.ParentKey THEN t.Parent_value  WHEN m.SelectedKey = m.ChildKey THEN t.Child_Value ELSE NULL END AS SelectedValue  
 FROM @TEMP_RESULT t, tblMergeDetails m, #TEMP_AIRPORT_CHILD c WHERE t.ID = m.ID AND t.ID = c.ID 

END
GO
