-- =============================================
-- Author:		Sathya
-- Create date: 06/24/2022
-- Description:	Returns list of child config for given config id if queued for locking and its not modified since last x hrs and not cancelled.
-- =============================================
GO
IF OBJECT_ID('[dbo].[SP_getConfigIdsToBeLocked]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_getConfigIdsToBeLocked]
END
GO
CREATE PROC SP_getConfigIdsToBeLocked  
@timeInterval INT,  
@taskTypeId UNIQUEIDENTIFIER  
AS  
BEGIN  
  SET @timeInterval=@timeInterval*-1  
  
  SELECT ID,TaskDataJSON,task.ConfigurationID,task.ConfigurationDefinitionID,StartedByUserID FROM tblTasks(nolock) task INNER JOIN tblConfigurations(nolock) config ON  
  config.ConfigurationID= task.ConfigurationID WHERE TaskTypeID=@taskTypeId AND TaskStatusID     
  IN(SELECT id  FROM tblTaskStatus WHERE name='Not Started') AND  (config.LastUpdateDateTime IS NULL OR config.LastUpdateDateTime<DATEADD(MINUTE, @timeInterval, GETDATE()))
  AND task.Cancelled=0
  
END  

GO