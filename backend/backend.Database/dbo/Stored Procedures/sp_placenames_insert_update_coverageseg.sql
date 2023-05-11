-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	inserts or updates the coveragesegment information
-- =============================================
GO

IF OBJECT_ID('[dbo].[sp_placenames_insert_update_coverageseg]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_insert_update_coverageseg]
END
GO
CREATE PROC sp_placenames_insert_update_coverageseg
@configurationId INT,
@geoRefId INT,
@covSegmentId INT=0,
@lat1 VARCHAR(200),
@lon1 VARCHAR(200),
@lat2 VARCHAR(200),
@lon2 VARCHAR(200)
AS
BEGIN
IF @covSegmentId IS NULL OR @covSegmentId=0
BEGIN
INSERT INTO tblCoverageSegment(GeoRefID,SegmentID,Lat1,Lon1,Lat2,Lon2,DataSourceID)
VALUES(@geoRefId,1,@lat1,@lon1,@lat2,@lon2,-3)
SELECT @covSegmentId=SCOPE_IDENTITY();

EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblCoverageSegment',@covSegmentId;

END
ELSE
BEGIN
	declare @updateKey int
	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblCoverageSegment', @covSegmentId, @updateKey out

	UPDATE tblCoverageSegment SET Lat1=@lat1,Lon1=@lon1,Lat2=@lat2,Lon2=@lon2 WHERE id=@updateKey
END
END
GO