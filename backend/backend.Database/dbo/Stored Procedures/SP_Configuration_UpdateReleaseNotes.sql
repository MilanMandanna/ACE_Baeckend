SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	updates the release notes for given cinfiguration and given version
-- Sample EXEC [dbo].[SP_Configuration_UpdateReleaseNotes] 1,1 'release noetes'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_UpdateReleaseNotes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_UpdateReleaseNotes]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_UpdateReleaseNotes]
	@configurationId INT,
    @version INT,
    @releaseNotes VARCHAR(MAX)

AS
BEGIN

	DECLARE @comments NVARCHAR(MAX) = ''

	SET @comments = (SELECT ISNULL(LockComment, '') FROM tblConfigurations WHERE ConfigurationID = @configurationId AND Version = @version)

	SET @comments = @comments + ' ' + @releaseNotes

    UPDATE dbo.tblConfigurations
    SET dbo.tblConfigurations.LockComment = @comments
    WHERE dbo.tblConfigurations.ConfigurationID = @configurationId AND dbo.tblConfigurations.Version = @version
END
GO