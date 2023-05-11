SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for branching the given configuration
-- SP executes the SP_CreateBranch procedure to branch out the given configuration.
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'Guid of the user'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_BranchConfiguration]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_BranchConfiguration]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_BranchConfiguration]
	@configurationId INT,
    @LastModifiedBy VARCHAR(MAX)
AS
BEGIN

    DECLARE @IntoConfigurationDefinitionID INT;
    SET @IntoConfigurationDefinitionID = (SELECT  dbo.tblConfigurations.ConfigurationDefinitionID FROM dbo.tblConfigurations WHERE dbo.tblConfigurations.ConfigurationID = @configurationId);
	BEGIN TRY
		BEGIN TRANSACTION

			-- Execute SP to Creare braching of configuration.
			EXECUTE dbo.SP_CreateBranch @configurationId,@IntoConfigurationDefinitionID,@LastModifiedBy,'Branching by Locking Configuration'

		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH
END
GO