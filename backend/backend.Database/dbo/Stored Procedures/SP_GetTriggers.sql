
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada		
-- Create date: 5/25/2022
-- Description:	This sp will return name,condition,type based on configurationid
-- Sample: EXEC [dbo].[SP_GetTriggers] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetTriggers]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetTriggers]
END
GO

CREATE PROCEDURE [dbo].[SP_GetTriggers]
        @configurationId INT
       
AS

BEGIN
        SELECT DISTINCT
                isnull(Nodes.TriggerItem.value('(./@name)[1]', 'varchar(max)'),'') as Name,
                isnull(Nodes.TriggerItem.value('(./@condition)[1]', 'varchar(max)'),'') as Condition,
                isnull(Nodes.TriggerItem.value('(./@id)[1]', 'varchar(max)'),'') as Id,
                isnull(Nodes.TriggerItem.value('(./@type)[1]', 'varchar(max)'),'') as Type,
                isnull(Nodes.TriggerItem.value('(./@default)[1]', 'varchar(max)'),'false') as IsDefault
                FROM cust.tblTrigger as T
                cross apply T.TriggerDefs.nodes('/trigger_defs/trigger') as Nodes(TriggerItem)
                INNER JOIN cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID 
                AND cust.tblTriggerMap.ConfigurationID = @configurationId
       
END
GO


