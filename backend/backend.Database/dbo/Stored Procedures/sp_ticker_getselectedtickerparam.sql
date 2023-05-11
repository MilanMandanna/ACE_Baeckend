
/****** Object:  StoredProcedure [dbo].[sp_ticker_getselectedtickerparam]    Script Date: 1/30/2022 9:30:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	retunrs selected ticker params for config
-- Sample EXEC [dbo].[sp_ticker_getselectedtickerparam] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getselectedtickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getselectedtickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_getselectedtickerparam]
@configurationId INT
AS
BEGIN
SELECT  Nodes.InfoItem.value('(.)[1]','varchar(max)') as Parameter 
                FROM 
                cust.tblWebMain as WebMain 
                cross apply WebMain.InfoItems.nodes('/infoitems/infoitem[@ticker= "true"]') as Nodes(InfoItem) 
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID 
                AND cust.tblWebMainMap.ConfigurationID = @configurationId
END
GO

