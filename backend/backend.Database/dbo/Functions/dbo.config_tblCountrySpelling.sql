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

IF OBJECT_ID('dbo.config_tblCountrySpelling') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[config_tblCountrySpelling]
END
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 1/08/2022
-- Description:	Function returns the tblCountrySpelling data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblCountrySpelling
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblCountrySpelling.*
	from tblCountrySpelling 
		inner join tblCountrySpellingMap on tblCountrySpellingMap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
	where tblCountrySpellingMap.ConfigurationID = @configurationId
		and tblCountrySpellingMap.isDeleted = 0
)
GO
