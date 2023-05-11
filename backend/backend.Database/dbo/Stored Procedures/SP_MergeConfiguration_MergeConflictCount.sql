GO
DROP PROC IF EXISTS SP_MergeConfiguration_MergeConflictCount
GO
CREATE PROC SP_MergeConfiguration_MergeConflictCount
@taskId UNIQUEIDENTIFIER 
AS
BEGIN
SELECT COUNT(1) AS count FROM tblMergeDetails WHERE TaskId=@taskId
END