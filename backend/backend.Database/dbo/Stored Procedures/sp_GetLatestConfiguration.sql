GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetLatestConfiguration]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetLatestConfiguration]
END
GO
CREATE PROC sp_GetLatestConfiguration 
@configurationDefinitionId INT
AS
BEGIN

select 
  tblConfigurations.*
from tblConfigurations
where configurationid = (
  select
    max(configurationid)
  from tblConfigurations
  where
    ConfigurationDefinitionID = @configurationDefinitionId
)

END

GO