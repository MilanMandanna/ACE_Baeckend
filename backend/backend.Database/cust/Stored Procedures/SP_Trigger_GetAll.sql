-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Retrieves all triggers in the trigger xml element for a specific configuration.
--   Each trigger element is returned as a separate record
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_GetAll]
END
GO
CREATE PROCEDURE [cust].[SP_Trigger_GetAll]
	@configurationId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		isnull(Nodes.TriggerItem.value('(./@name)[1]', 'varchar(max)'),'') as Name,
		isnull(Nodes.TriggerItem.value('(./@condition)[1]', 'varchar(max)'),'') as Condition,
		isnull(Nodes.TriggerItem.value('(./@id)[1]', 'varchar(max)'),'') as Id,
		isnull(Nodes.TriggerItem.value('(./@type)[1]', 'varchar(max)'),'') as Type,
		isnull(Nodes.TriggerItem.value('(./@default)[1]', 'varchar(max)'),'false') as IsDefault
	FROM cust.tblTrigger as T
		cross apply T.TriggerDefs.nodes('/trigger_defs/trigger') as Nodes(TriggerItem)
		inner join cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID 
			and cust.tblTriggerMap.ConfigurationID = @configurationId
			and cust.tblTriggerMap.IsDeleted = 0
END

GO