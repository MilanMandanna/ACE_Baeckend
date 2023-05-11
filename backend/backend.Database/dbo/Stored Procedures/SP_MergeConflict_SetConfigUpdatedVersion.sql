GO
DROP PROC IF EXISTS SP_MergeConflict_SetConfigUpdatedVersion
GO
CREATE PROC SP_MergeConflict_SetConfigUpdatedVersion
@parentConfigId INT,
@childConfigDefId INT
AS
BEGIN

DECLARE @version INT;

SELECT @version=Version FROM tblConfigurations WHERE ConfigurationID=@parentConfigId;

UPDATE tblConfigurationDefinitions SET UpdatedUpToVersion=@version WHERE ConfigurationDefinitionID=@childConfigDefId;

END

GO