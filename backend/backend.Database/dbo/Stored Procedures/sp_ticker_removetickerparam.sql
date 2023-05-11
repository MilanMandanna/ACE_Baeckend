
/****** Object:  StoredProcedure [dbo].[sp_ticker_removetickerparam]    Script Date: 1/30/2022 9:36:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	remove tikcer param
-- Sample EXEC [dbo].[sp_ticker_removetickerparam] 1, 'position'
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_removetickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_removetickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_removetickerparam]
@configurationId INT,
@tickeritem VARCHAR(200)
AS
BEGIN

UPDATE cust.tblWebMain 
                 SET InfoItems.modify('delete /infoitems/infoitem[text()][contains(.,sql:variable("@tickeritem"))]') 
                 WHERE cust.tblWebMain.WebMainID IN( 
                 SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap 
                 WHERE cust.tblWebMainMap.ConfigurationID = @configurationId 
                 ) 

END
GO

