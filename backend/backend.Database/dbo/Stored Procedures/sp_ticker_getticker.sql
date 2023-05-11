
/****** Object:  StoredProcedure [dbo].[sp_ticker_getticker]    Script Date: 1/30/2022 9:31:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	getting ticker details
-- Sample EXEC [dbo].[sp_ticker_getticker] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getticker]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getticker]
END
GO

CREATE PROC [dbo].[sp_ticker_getticker]
@configurationId INT
AS
BEGIN

SELECT 
                isnull(Ticker.value('(/ticker/@position)[1]', 'varchar(max)'),'bottom') as Position, 
                isnull(Ticker.value('(/ticker/@speed)[1]', 'INT'),'0') as Speed, 
                isnull(Ticker.value('(/ticker/@visible)[1]', 'varchar(max)'),'true') as Visible
                FROM cust.tblTicker 
                INNER JOIN cust.tblTickerMap ON cust.tblTickerMap.TickerID = cust.tblTicker.TickerID 
                AND cust.tblTickerMap.ConfigurationID = @configurationId

END
GO

