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

IF OBJECT_ID('dbo.config_tblRegionSpelling') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[config_tblRegionSpelling]
END
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 1/08/2022
-- Description:	Function returns the tblRegionSpelling data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblRegionSpelling
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblRegionSpelling.*
	from tblRegionSpelling 
		inner join tblRegionSpellingMap on tblRegionSpellingMap.SpellingID = tblRegionSpelling.SpellingID
	where tblRegionSpellingMap.ConfigurationID = @configurationId
		and tblRegionSpellingMap.isDeleted = 0
)
GO
