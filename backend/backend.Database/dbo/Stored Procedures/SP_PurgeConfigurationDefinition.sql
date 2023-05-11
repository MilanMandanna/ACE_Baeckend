-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
IF OBJECT_ID('[dbo].[SP_PurgeConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_PurgeConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_PurgeConfigurationDefinition]
	@configurationDefinitionId int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    delete from tblconfigurations where ConfigurationDefinitionID = @configurationDefinitionId;
	delete from tblConfigurationDefinitions where ConfigurationDefinitionID = @configurationDefinitionId;
END

GO