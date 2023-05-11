SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	this will update the ticker value
--EXEC [dbo].[sp_ticker_update] 67,'visible','false'
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_update]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[sp_ticker_update]
END
GO
CREATE PROCEDURE [dbo].[sp_ticker_update]
			@configurationId INT,
			@name NVARCHAR(Max),
			@value NVARCHAR(Max)
			
AS
BEGIN
		DECLARE @sql NVARCHAR(MAX),@UpdateKey int,@TickerID int,@params NVARCHAR(400)='@updatekey int'
		SET @TickerID = (SELECT  cust.tblTickerMap.TickerID FROM cust.tblTickerMap WHERE cust.tblTickerMap.ConfigurationID = @configurationId)
		EXEC SP_ConfigManagement_HandleUpdate @configurationId ,'tblTicker',@TickerID,@UpdateKey out
		SET  @sql ='UPDATE cust.tblTicker
              SET  Ticker.modify(''replace value of (/ticker/@' +@name + ')[1] with "'  + @value + '"'') 
              WHERE cust.tblTicker.TickerID  =@UpdateKey'
		EXEC sys.Sp_executesql @sql,@params,@UpdateKey=@UpdateKey
END
GO


