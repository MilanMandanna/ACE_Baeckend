SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 2/10/2022
-- Description:	Gets all the colors available in RLI xml
-- Sample EXEC [dbo].[SP_Compass_GetMakkahImageTextValues] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetMakkahImageTextValues]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetMakkahImageTextValues]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetMakkahImageTextValues]
	@configurationId int
AS
BEGIN
	SELECT rli.value('(rli/mecca_display/@image)[1]', 'varchar(max)') as imageValue,
	rli.value('(rli/mecca_display/@text)[1]', 'varchar(max)') as textValue
	FROM cust.config_tblRLI(@configurationId) as R 
END
GO