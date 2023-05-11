GO
DROP FUNCTION IF EXISTS [dbo].[config_tblFontCategory]
GO
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
-- Create date: 28/06/2022
-- Description:	Function returns the tblFontCategory data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblFontCategory
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblFontCategory.*
	from tblFontCategory 
		inner join tblFontCategoryMap on tblFontCategoryMap.FontCategoryID = tblFontCategory.FontCategoryID
	where tblFontCategoryMap.ConfigurationID = @configurationId
		and tblFontCategorymap.isDeleted = 0
)
GO
