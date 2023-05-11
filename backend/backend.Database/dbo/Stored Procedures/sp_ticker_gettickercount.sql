/****** Object:  StoredProcedure [dbo].[sp_ticker_gettickercount]    Script Date: 1/30/2022 9:33:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	returns ticker details
-- Sample EXEC [dbo].[sp_ticker_gettickercount] 'position', 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_gettickercount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_gettickercount]
END
GO

CREATE PROC [dbo].[sp_ticker_gettickercount]
@name VARCHAR(200),
@configurationId INT
AS
BEGIN

 SELECT count(b.value('local-name(.)','VARCHAR(MAX)'))
FROM cust.tblTicker b
  INNER JOIN cust.tblTickerMap c ON b.TickerID = c.TickerID 
  CROSS APPLY b.Ticker.nodes('/ticker') test(item) cross apply item.nodes('@*') a(b) WHERE ConfigurationID=@configurationId  
  AND b.value('local-name(.)','VARCHAR(MAX)')=@name

END
GO

