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
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 12/07/2022
-- Description:	Function returns the tblFont data for given configuration id
-- =============================================
DROP FUNCTION IF EXISTS dbo.config_tblFont
GO

CREATE FUNCTION dbo.config_tblFont
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblFont.*
	from tblFont 
		inner join tblFontMap on tblFontMap.FontID = tblFont.FontID
	where tblFontMap.ConfigurationID = @configurationId
		and tblFontmap.isDeleted = 0
)
GO
