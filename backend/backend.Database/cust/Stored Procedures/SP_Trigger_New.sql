-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Creates a new trigger record with the default trigger xml element in place.
--   The newly created trigger id is returned as an output parameter
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_New]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_New]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_New]
	@triggerId int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @triggerIds table (TriggerId int)
    INSERT INTO cust.tblTrigger
		(TriggerDefs)
	OUTPUT inserted.TriggerId into @triggerIds
	VALUES('<trigger_defs/>')

	set @triggerId = scope_identity()
END

GO
