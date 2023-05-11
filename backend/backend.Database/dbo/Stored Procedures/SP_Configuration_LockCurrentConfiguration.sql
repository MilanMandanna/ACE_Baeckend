SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for Locking the given configuration
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'lockMessage'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_LockCurrentConfiguration]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_LockCurrentConfiguration]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_LockCurrentConfiguration]
	@configurationId INT,
    @lockMessage NVARCHAR(MAX),
	@userId NVARCHAR(200),
	@taskId NVARCHAR(100)
AS
BEGIN

    BEGIN TRANSACTION
		
		DECLARE @userName NVARCHAR(250), @lockingComments NVARCHAR(MAX) = ''
		
		SELECT @lockingComments = @lockingComments + CONVERT(NVARCHAR, CONVERT(date, DateModified), 3) + '-' + COALESCE(UserComments + ',','') + '  '
		FROM tblConfigurationHistory where ConfigurationID = @configurationId AND UserComments IS NOT NULL AND DateModified IS NOT NULL
		AND ContentType IN ('populations','airports','world guide cities','Merging Configuration')

		IF len(@lockingComments)>0
		BEGIN
		SET @lockMessage = @lockMessage + '  ' + Left(@lockingComments,len(@lockingComments)-1)
		END
		SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)
        -- Update locked value for the current configuration
        UPDATE dbo.tblConfigurations 
        SET dbo.tblConfigurations.Locked = 1, dbo.tblConfigurations.LockComment = @lockMessage , dbo.tblConfigurations.LockDate = GETDATE()
        WHERE dbo.tblConfigurations.ConfigurationID = @configurationId;

		INSERT INTO tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID, UserComments)
		VALUES (@configurationId, 'Locking Configuration', @userName, GETDATE(), @taskId, @lockMessage)

    COMMIT
END
GO