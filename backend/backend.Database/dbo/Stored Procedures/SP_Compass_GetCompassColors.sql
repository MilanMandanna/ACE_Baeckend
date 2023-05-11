SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 2/10/2022
-- Description:	Gets all the colors available in RLI xml
-- Sample EXEC [dbo].[SP_Compass_AddCompassAirplanes] 18, '1,2'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetCompassColors]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetCompassColors]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetCompassColors]
	@configurationId int
AS
BEGIN
	SELECT rli.value('(rli/loc1/@color)[1]', 'varchar(max)') as Location_1_Color,
	rli.value('(rli/loc2/@color)[1]', 'varchar(max)') as Location_2_Color,
	rli.value('(rli/compass/@color)[1]', 'varchar(max)') as CompassColorPlaceholder,
	rli.value('(rli/north_text/@color)[1]', 'varchar(max)') as NorthTextColor,
	rli.value('(rli/north_base/@color)[1]', 'varchar(max)') as NorthBaseColor,
	rli.value('(rli/poi_text/@color)[1]', 'varchar(max)') as POIColor,
	rli.value('(rli/value_text/@color)[1]', 'varchar(max)') as ValueTextColor
	FROM cust.config_tblRLI(@configurationId) as R
END
