SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/03/2022
-- Description:	Gets the default locking comments from tblConfigurationHistory table
-- Sample EXEC [dbo].[SP_Configuration_GetDefaultLockingComments] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetDefaultLockingComments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetDefaultLockingComments]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetDefaultLockingComments]
	@configurationId INT
AS
BEGIN

SELECT
   CASE WHEN  dbo.tblConfigurationHistory.UserComments is null THEN '' ELSE dbo.tblConfigurationHistory.UserComments END 
   FROM dbo.tblConfigurationHistory
   WHERE dbo.tblConfigurationHistory.ConfigurationId = @configurationId
END
GO