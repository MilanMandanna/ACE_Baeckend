CREATE TABLE [cust].[tblTicker]
(
	[TickerID] int NOT NULL IDENTITY (1, 1),
	[Ticker] xml NULL
)
GO
ALTER TABLE [cust].[tblTicker] 
 ADD CONSTRAINT [PK_tblTicker]
	PRIMARY KEY CLUSTERED ([TickerID] ASC)