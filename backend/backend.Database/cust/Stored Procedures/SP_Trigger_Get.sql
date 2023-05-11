-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Returns a single trigger from a configuration. The XML is decomposed in to individual fields of a record.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Get]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Get]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Get]
	@configurationId int,
	@triggerId int
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
		cross apply T.TriggerDefs.nodes('/trigger_defs/trigger[@id = sql:variable("@triggerId")]') as Nodes(TriggerItem)
		INNER JOIN cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID AND cust.tblTriggerMap.ConfigurationID = @configurationId and cust.tblTriggerMap.IsDeleted = 0
END

GO