-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/17/2022
-- Description:	Removes a trigger from the trigger configuration associated with the specified
--   configuration id. If no trigger record is present, then no action is taken.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Delete]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Delete]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Delete]
	@configurationId int,
	@triggerId int
AS
BEGIN
	set nocount on
	declare @mappedTriggerId int = (select triggerId from tblTriggerMap where configurationId = @configurationId)

	-- if there is a trigger defined for this configuration then attempt to remove the specified
	-- trigger
	if not @mappedTriggerId is null
	begin
		declare @updateKey int
		exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblTrigger', @mappedTriggerId, @updateKey out

		set nocount off
		update cust.tblTrigger
		set TriggerDefs.modify('delete /trigger_defs/trigger[@id = sql:variable("@triggerId")]')
		where TriggerID = @updateKey
	end
END

GO