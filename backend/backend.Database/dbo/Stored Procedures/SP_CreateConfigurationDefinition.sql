IF OBJECT_ID('[dbo].[SP_CreateConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_CreateConfigurationDefinition]
	@ParentConfigurationDefinitionID int,
	@NewConfigurationDefinitionID int,
	@ConfigurationTypeID int = 1,
	@OutputTypeID int = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	INSERT INTO tblConfigurationDefinitions (ConfigurationDefinitionID, ConfigurationDefinitionParentID, ConfigurationTypeID, OutputTypeID, Active, AutoLock, AutoDeploy)
	SELECT @NewConfigurationDefinitionID, ConfigurationDefinitionID, @ConfigurationTypeID, @OutputTypeID, 1, 1, 1 FROM tblConfigurationDefinitions WHERE tblConfigurationDefinitions.ConfigurationDefinitionID = @ParentConfigurationDefinitionID;


END

GO