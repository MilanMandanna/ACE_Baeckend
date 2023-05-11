

DROP PROC IF EXISTS SP_CheckAndCreateTicker
GO
CREATE PROC SP_CheckAndCreateTicker
@configurationId INT
AS
BEGIN
DECLARE @count INT

SELECT @count=COUNT(1) from cust.tblTickerMap WHERE ConfigurationID=@configurationId

IF @count=0
BEGIN
DECLARE @tickerXML NVARCHAR(MAX)='<ticker position="bottom" speed="0" visible="true" />'
INSERT INTO cust.tblTicker(Ticker) VALUES(@tickerXML);

DECLARE @ticketId INT

SELECT @ticketId=SCOPE_IDENTITY();

EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblTicker',@ticketId
SELECT @ticketId
END
ELSE
SELECT 1
END
