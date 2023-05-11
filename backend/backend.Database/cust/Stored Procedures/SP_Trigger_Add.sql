-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Adds a trigger record to the specified configuration.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Add]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Add]
	@configurationId int,
	@name varchar(max),
	@type varchar(max),
	@condition varchar(max),
	@default varchar(max)
AS
BEGIN
	set nocount on

	-- check for and  create a trigger record if one is not present for the configuration
	-- this should never occur because the flow down from the global configuration should always have a record,
	-- but just in case!!!
    declare @triggerId int
	declare @id int

	set @triggerId = (select triggerId from tblTriggerMap where ConfigurationID = @configurationId)

	if @triggerId is null
	begin
		exec cust.SP_Trigger_New @triggerId = @triggerId output
		exec dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblTrigger', @triggerId
	end

	-- create and add the trigger node to the configuration
	--
	set @id = ( select MAX(Nodes.TriggerValues.value('(./@id)[1]','int'))
				from 
				cust.tblTrigger as TriggerTable
				cross apply TriggerTable.TriggerDefs.nodes('trigger_defs/trigger') as Nodes(TriggerValues)
				inner join cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = TriggerTable.TriggerID 
				and cust.tblTriggerMap.ConfigurationID = @configurationId AND cust.tblTriggerMap.IsDeleted = 0)
	if @id is null
	begin
        set @id = 0
	end

	declare @triggerDefinition varchar(max) =
		'<trigger condition="' + @condition + '" default="' + @default + '" id="' + cast((@id + 1) as varchar) + '" name="' + @name + '" type="' + @type + '"/>'
	declare @triggerNode xml = cast(@triggerDefinition as xml)

	set nocount off
	update cust.tblTrigger
	set TriggerDefs.modify('insert sql:variable("@triggerNode") into /trigger_defs[1]')
	where cust.tblTrigger.TriggerID = @triggerId;

END

GO