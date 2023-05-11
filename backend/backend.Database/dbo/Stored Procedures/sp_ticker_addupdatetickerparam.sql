
/****** Object:  StoredProcedure [dbo].[sp_ticker_addupdatetickerparam]    Script Date: 1/30/2022 9:26:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add ticker param
-- Sample EXEC [dbo].[sp_ticker_addupdatetickerparam] 1,''
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_addupdatetickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_addupdatetickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_addupdatetickerparam]
@configurationId INT,
@xmlValue xml
AS
BEGIN
UPDATE 
                cust.tblWebMain
                SET InfoItems = @xmlValue
                 WHERE cust.tblWebMain.WebMainID IN (
	                SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap
	                WHERE cust.tblWebMainMap.ConfigurationID = @configurationId
	                )
END
GO

