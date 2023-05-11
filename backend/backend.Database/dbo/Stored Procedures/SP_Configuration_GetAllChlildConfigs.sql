
GO
IF OBJECT_ID('[dbo].[SP_Configuration_GetAllChlildConfigs]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetAllChlildConfigs]
END
GO
CREATE PROC [dbo].[SP_Configuration_GetAllChlildConfigs] @configId INT

AS

BEGIN
declare @parentDefinitionId int = (select configurationdefinitionid from tblConfigurations where configurationid = @configId);


select
--*
tblconfigurations.configurationid
from tblconfigurations
inner join tblConfigurationDefinitions
on tblconfigurations.ConfigurationDefinitionID = tblConfigurationDefinitions.ConfigurationDefinitionID
inner join (
select
max(version) as version,
configurationdefinitionid
from tblconfigurations
group by ConfigurationDefinitionID
) versions on versions.version = tblconfigurations.version and versions.ConfigurationDefinitionID = tblconfigurations.ConfigurationDefinitionID

inner join tblConfigurationTypes on tblConfigurationTypes.ConfigurationTypeID = tblConfigurationDefinitions.ConfigurationTypeID
where
tblConfigurationDefinitions.ConfigurationDefinitionParentID = @parentDefinitionId
and tblconfigurations.ConfigurationDefinitionID != @parentDefinitionId
and tblconfigurations.locked = 0;


  END

GO

