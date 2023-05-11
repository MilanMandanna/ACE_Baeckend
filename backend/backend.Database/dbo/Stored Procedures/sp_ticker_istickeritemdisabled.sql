
/****** Object:  StoredProcedure [dbo].[sp_ticker_istickeritemdisabled]    Script Date: 1/30/2022 9:34:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	checks if the ticker disabled
-- Sample EXEC [dbo].[sp_ticker_istickeritemdisabled] 1, 'position'
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_istickeritemdisabled]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_istickeritemdisabled]
END
GO

CREATE PROC [dbo].[sp_ticker_istickeritemdisabled]
@configurationId INT,
@tickeritem VARCHAR(200)
AS
BEGIN

SELECT 
                COUNT(*) 
                FROM 
                cust.tblWebMain as WebMain 
                cross apply WebMain.InfoItems.nodes('/infoitems/infoitem') as Nodes(InfoItem)
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID 
                AND cust.tblWebMainMap.ConfigurationID = @configurationId AND Nodes.InfoItem.value('(.)[1]', 'varchar(max)') like '%'+@tickeritem+'%' 
                WHERE Nodes.InfoItem.value('(./@ticker)[1]', 'varchar(max)') like '%false%'

END
GO

