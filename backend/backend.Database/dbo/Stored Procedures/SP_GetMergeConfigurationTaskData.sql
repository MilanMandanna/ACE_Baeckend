DROP PROC IF EXISTS [dbo].[SP_GetMergeConfigurationTaskData]  
  GO
CREATE PROCEDURE [dbo].[SP_GetMergeConfigurationTaskData]  
 @configurationId INT  
AS  
BEGIN  
 SELECT task.ID,Name,TaskStatusID FROM tblTasks task INNER JOIN tblTaskType tType ON task.TaskTypeID=tType.ID  WHERE ConfigurationID = @configurationId AND  
 tType.Name in('ui merge configuration','PerformDataMerge') ORDER BY DateLastUpdated DESC

END  

GO