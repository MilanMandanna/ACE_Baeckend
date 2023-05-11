-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
IF OBJECT_ID('[dbo].[SP_CopyConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CopyConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_CopyConfigurationDefinition]
	@sourceConfigurationDefinitionId int = 0,
	@destinationConfigurationDefinitionId int = 0,
	@description nvarchar(max) = ''
AS
BEGIN
	set nocount on;

	declare @configurationId int;
	set @configurationId = (select max(configurationid) from tblconfigurations where ConfigurationDefinitionID = @sourceConfigurationDefinitionId);

	execute sp_createbranch @configurationId, @destinationConfigurationDefinitionId, 'Script', @description

END

GO