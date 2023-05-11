SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 09/28/2022
-- Description:	To get version number locked date and release notes for given configurationid
-- Sample EXEC [dbo].[SP_MergeConfig_GetUpdatesDetails] 2
-- =============================================

IF OBJECT_ID('[dbo].[SP_MergeConfig_GetUpdatesDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_MergeConfig_GetUpdatesDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_MergeConfig_GetUpdatesDetails]
	@configurationDefinitionID INT
AS
BEGIN

DECLARE @parentVersion INT
DECLARE @ChildVersion INT,@parentDefId INT

select @parentDefId=ConfigurationDefinitionParentID from tblConfigurationDefinitions where ConfigurationDefinitionID=@configurationDefinitionID and ConfigurationDefinitionParentID>0 and ConfigurationDefinitionParentID!=ConfigurationDefinitionID

select @ChildVersion= ISNULL(CD.UpdatedUpToVersion, 0)
from tblConfigurations C INNER JOIN tblConfigurationDefinitions CD on c.ConfigurationDefinitionID=cd.ConfigurationDefinitionID
where cd.ConfigurationDefinitionID=@configurationDefinitionID and c.Locked=1 group by c.ConfigurationDefinitionID,CD.UpdatedUpToVersion

	SELECT C.Version, C.LockDate, C.LockComment, C.ConfigurationID FROM tblConfigurations C 
	WHERE  Locked = 1 AND C.ConfigurationDefinitionID = @parentDefId AND Version>@ChildVersion
	
	ORDER BY C.Version DESC
END
GO