
/****** Object:  StoredProcedure [dbo].[sp_ticker_getinfoitems]    Script Date: 1/30/2022 9:29:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get all ticer info items
-- Sample EXEC [dbo].[sp_ticker_getinfoitems] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getinfoitems]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getinfoitems]
END
GO

CREATE PROC [dbo].[sp_ticker_getinfoitems]
@configurationId INT
AS 
BEGIN
SELECT 
                InfoItems
                FROM cust.tblWebMain
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
                AND cust.tblWebMainMap.ConfigurationID = @configurationId
END
GO

