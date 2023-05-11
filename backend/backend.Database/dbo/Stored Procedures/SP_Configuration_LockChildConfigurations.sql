SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for Locking the child configurations of the given config id.
-- checks if the parent configuraion definition id is set to autolock, if true then locks all child config ids corresponding to the definition id.
-- SP also returns the list of configuration ids that got locked.
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'lockMessage'
-- =============================================


IF OBJECT_ID('[dbo].[SP_Configuration_LockChildConfigurations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_LockChildConfigurations]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_LockChildConfigurations]
	@configurationId INT,
    @lockMessage NVARCHAR(MAX),
	@userId NVARCHAR(200),
	@taskId NVARCHAR(100)
AS
BEGIN

    BEGIN TRANSACTION
		
		DECLARE @tempTable TABLE(configurationId INT)
		DECLARE @configId INT, @userName NVARCHAR(200), @lockingComments NVARCHAR(MAX) = ''

        -- For each child configuration, If the child is marked as AutoLock, lock the child configurations
		DROP TABLE IF EXISTS #tempconfigid
		CREATE TABLE #tempconfigid(configurationid INT);
		INSERT INTO #tempconfigid Exec [dbo].[SP_Configuration_GetAllChlildConfigs] @configurationId
        
		INSERT INTO @tempTable SELECT * FROM #tempconfigid

		-- Get user name from the userId
		SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)

        -- Update the configuration table for the latest configurations associated with above list of configuration Definition Id
        UPDATE tblConfig
        SET tblConfig.Locked = C.Locked, tblConfig.LockComment = C.LockComment ,tblConfig.LockDate = GETDATE()
        FROM dbo.tblConfigurations as tblConfig
        INNER JOIN 
        (
            SELECT dbo.tblConfigurations.ConfigurationDefinitionID,
            Max(dbo.tblConfigurations.Version) as Version,
            1 AS  Locked,
            @lockMessage AS LockComment 
            FROM dbo.tblConfigurations
            WHERE dbo.tblConfigurations.configurationid 
                IN (
                SELECT configurationid FROM #tempconfigid
                )
            GROUP BY  dbo.tblConfigurations.ConfigurationDefinitionID 
        ) AS C ON tblConfig.ConfigurationDefinitionID = C.ConfigurationDefinitionID
          AND tblConfig.Version = C.Version
        
		WHILE (SELECT COUNT(*) FROM @tempTable) > 0
		BEGIN
			SET @configId = (SELECT TOP 1 configurationId FROM @tempTable)

			SELECT @lockingComments = @lockingComments + CONVERT(NVARCHAR, CONVERT(date, DateModified), 3) + '-' + COALESCE(UserComments + ',','') + '  '
			FROM tblConfigurationHistory where ConfigurationID = @configId AND UserComments IS NOT NULL AND DateModified IS NOT NULL
			AND ContentType IN ('populations','airports','world guide cities','Merging Configuration')

			SET @lockMessage = @lockMessage + '  ' + Left(@lockingComments,len(@lockingComments)-1)

			INSERT INTO tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID, UserComments)
			VALUES (@configId, 'Locking Configuration', @userName, GETDATE(), @taskId, @lockMessage)

			DELETE FROM @tempTable WHERE configurationId = @configId
		END
		SELECT configurationid FROM #tempconfigid

    COMMIT
END
GO