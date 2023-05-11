
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date:  5/25/2022
-- Description:	This will return the info parameters 
-- Sample: EXEC [dbo].[SP_GetFlightInfoViewParameters] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFlightInfoViewParameters]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFlightInfoViewParameters]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFlightInfoViewParameters]
       @configurationId INT
       
AS

BEGIN
     
           SELECT DISTINCT Nodes.item.value('(.)[1]', 'VARCHAR(MAX)') as info_params
            FROM cust.tblWebMain CROSS APPLY InfoItems.nodes('/infoitems/infoitem') Nodes(item)
			INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.ConfigurationID = tblWebMainMap.ConfigurationID 
             WHERE tblWebMainMap.ConfigurationID = @configurationId
END
GO
