GO
DROP FUNCTION IF EXISTS [dbo].[config_tblFontFamily]
GO
/****** Object:  UserDefinedFunction [dbo].[config_tblFontFamily]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 12/12/2022
-- Description:	Function returns the tblFont data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblFontFamily
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblFontFamily.*
	from tblFontFamily 
		inner join tblFontFamilyMap on tblFontFamilyMap.FontFamilyID = tblFontFamily.FontFamilyID
	where tblFontFamilyMap.ConfigurationID = @configurationId
		and tblFontFamilyMap.isDeleted = 0
)
