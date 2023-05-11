-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.config_tblFontMarker') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[config_tblFontMarker]
END
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 12/07/2022
-- Description:	Function returns the tblFontMarker data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblFontMarker
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblFontMarker.*
	from tblFontMarker 
		inner join tblFontMarkerMap on tblFontMarkerMap.FontMarkerID = tblFontMarker.FontMarkerID
	where tblFontMarkerMap.ConfigurationID = @configurationId
		and tblFontMarkermap.isDeleted = 0
)
GO
