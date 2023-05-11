SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	updates isHF/isUHF flag for given inset id for given configuration
-- Sample EXEC [dbo].[SP_AsxiInset_UpdateCity] '1','hf',1
-- =============================================

IF OBJECT_ID('[dbo].[SP_AsxiInset_UpdateCity]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInset_UpdateCity]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInset_UpdateCity]
    @configurationId Int,
	@type VARCHAR(MAX),
	@selected BIT,
	@ASXiInsetID INT,
	@action NVARCHAR(250)
AS
BEGIN
	IF (@action = 'insert')
	BEGIN
		INSERT INTO tblASXiInsetMap (ConfigurationID, ASXiInsetID,PreviousASXiInsetID,IsDeleted,Action)
		VALUES (@configurationId, @ASXiInsetID, 0, 0, 'adding')
	END
	ELSE IF (@action = 'delete')
	BEGIN
		UPDATE tblASXiInsetMap SET IsDeleted = 1 WHERE ASXiInsetID = @ASXiInsetID AND ConfigurationID = @configurationId
	END
END
GO